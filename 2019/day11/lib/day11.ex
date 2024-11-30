defmodule Day11 do
  def part1(program) do
    robot = operate_robot(program)
    Robot.num_painted_panels(robot)
  end

  def part2(program) do
    robot = operate_robot(program, %{{0,0} => 1})
    Robot.draw_grid(robot)
  end

  defp operate_robot(program, initial_grid \\ %{}) do
    machine = Intcode.new(program)
    robot = spawn(fn -> robot(machine, initial_grid) end)
    Intcode.set_sink(machine, robot)
    Intcode.go(machine)
    send(robot, :go)
    receive do
      {:halted, ^machine} ->
	Intcode.terminate(machine)
	send(robot, {:done, self()})
	receive do
	  robot -> robot
	end
    end
  end

  defp robot(machine, initial_grid) do
    robot = Robot.new(initial_grid)
    receive do
      :go ->
	robot_loop(robot, machine)
    end
  end

  defp robot_loop(robot, machine) do
    color = Robot.read_color(robot)
    send(machine, color)
    receive do
      color ->
	case color do
	  {:done, from} ->
	    send(from, robot)
	  _ ->
	    receive do
	      turn ->
		robot = Robot.move(robot, color, turn)
		robot_loop(robot, machine)
	    end
	end
    end
  end

  # The following functions are only used by the test suite.

  def test_robot(moves) do
    robot = Robot.new()
    robot = move_robot(robot, moves)
    Robot.num_painted_panels(robot)
  end

  defp move_robot(robot, [color, turn | moves]) do
    robot = Robot.move(robot, color, turn)
    move_robot(robot, moves)
  end
  defp move_robot(robot, []), do: robot
end

defmodule Intcode do
  def new(program) do
    spawn(fn -> machine(program) end)
  end

  def set_sink(machine, sink) do
    send(machine, {:set_sink, sink})
  end

  def go(machine) do
    send(machine, {:go, self()})
  end

  def terminate(machine) do
    send(machine, :terminate)
  end

  defp machine(input) do
    memory = read_program(input)
    machine_loop(memory)
  end

  defp machine_loop(memory) do
    receive do
      {:set_sink, sink} ->
	memory = Map.put(memory, :sink, sink)
	machine_loop(memory)
      {:go, from} ->
	memory = execute(memory)
	send(from, {:halted, self()})
	machine_loop(memory)
      :terminate ->
	nil
    end
  end

  defp execute(memory, ip \\ 0) do
    {opcode, modes} = fetch_opcode(memory, ip)
    case opcode do
      1 ->
	memory = exec_arith_op(&+/2, modes, memory, ip)
	execute(memory, ip + 4)
      2 ->
	memory = exec_arith_op(&*/2, modes, memory, ip)
	execute(memory, ip + 4)
      3 ->
	memory = exec_input(modes, memory, ip)
	execute(memory, ip + 2)
      4 ->
	memory = exec_output(modes, memory, ip)
	execute(memory, ip + 2)
      5 ->
	ip = exec_if(&(&1 !== 0), modes, memory, ip)
	execute(memory, ip)
      6 ->
	ip = exec_if(&(&1 === 0), modes, memory, ip)
	execute(memory, ip)
      7 ->
	memory = exec_cond(&(&1 < &2), modes, memory, ip)
	execute(memory, ip + 4)
      8 ->
	memory = exec_cond(&(&1 === &2), modes, memory, ip)
	execute(memory, ip + 4)
      9 ->
	memory = exec_inc_rel_base(modes, memory, ip)
	execute(memory, ip + 2)
      99 ->
	memory
    end
  end

  defp exec_arith_op(op, modes, memory, ip) do
    [in1, in2] = read_operand_values(memory, ip + 1, modes, 2)
    out_addr = read_out_address(memory, div(modes, 100), ip + 3)
    result = op.(in1, in2)
    write(memory, out_addr, result)
  end

  defp exec_input(modes, memory, ip) do
    out_addr = read_out_address(memory, modes, ip + 1)
    receive do
      value ->
        write(memory, out_addr, value)
    end
  end

  defp exec_output(modes, memory, ip) do
    [value] = read_operand_values(memory, ip + 1, modes, 1)
    sink = Map.fetch!(memory, :sink)
    send(sink, value)
    memory
  end

  defp exec_if(op, modes, memory, ip) do
    [value, new_ip] = read_operand_values(memory, ip + 1, modes, 2)
    case op.(value) do
      true -> new_ip
      false -> ip + 3
    end
  end

  defp exec_cond(op, modes, memory, ip) do
    [operand1, operand2] = read_operand_values(memory, ip + 1, modes, 2)
    out_addr = read_out_address(memory, div(modes, 100), ip + 3)
    result = case op.(operand1, operand2) do
	       true -> 1
	       false -> 0
	     end
    write(memory, out_addr, result)
  end

  defp exec_inc_rel_base(modes, memory, ip) do
    [offset] = read_operand_values(memory, ip + 1, modes, 1)
    base = get_rel_base(memory) + offset
    Map.put(memory, :rel_base, base)
  end

  defp read_operand_values(_memory, _addr, _modes, 0), do: []
  defp read_operand_values(memory, addr, modes, n) do
    operand = read(memory, addr)
    operand = case rem(modes, 10) do
		0 -> read(memory, operand)
		1 -> operand
		2 -> read(memory, operand + get_rel_base(memory))
	      end
    [operand | read_operand_values(memory, addr + 1, div(modes, 10), n - 1)]
  end

  defp read_out_address(memory, modes, addr) do
    out_addr = read(memory, addr)
    case modes do
      0 -> out_addr
      2 -> get_rel_base(memory) + out_addr
    end
  end

  defp fetch_opcode(memory, ip) do
    opcode = read(memory, ip)
    modes = div(opcode, 100)
    opcode = rem(opcode, 100)
    {opcode, modes}
  end

  defp get_rel_base(memory) do
    Map.get(memory, :rel_base, 0)
  end

  defp read(memory, addr) do
    Map.get(memory, addr, 0)
  end

  defp write(memory, addr, value) do
    Map.put(memory, addr, value)
  end

  defp read_program(input) do
    String.split(input, ",")
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index
    |> Stream.map(fn {code, index} -> {index, code} end)
    |> Map.new
  end
end

defmodule Robot do
  defstruct position: {0, 0}, direction: {0, 1}, grid: %{}

  def new(grid \\ %{}) do
    %Robot{grid: grid}
  end

  def read_color(robot) do
    Map.get(robot.grid, robot.position, 0)
  end

  def move(robot, color, turn) do
    pos = robot.position
    grid = Map.put(robot.grid, pos, color)
    {dx, dy} = robot.direction
    dir = case turn do
	    0 -> {-dy, dx}
	    1 -> {dy, -dx}
	  end
    pos = vec_add(pos, dir)
    %{robot | grid: grid, direction: dir, position: pos}
  end

  def num_painted_panels(robot) do
    map_size(robot.grid)
  end

  def draw_grid(robot) do
    IO.write("\n")
    grid = robot.grid
    {{min_col, _}, {max_col, _}} =
      grid
      |> Map.keys
      |> Enum.min_max_by(&(elem(&1, 0)))

    grid
    |> Enum.group_by(fn {{_col, row}, _color} -> row end)
    |> Enum.sort_by(fn {row, _} -> -row end)
    |> Enum.map(fn {_, row} -> draw_row(row, min_col..max_col) end)
    |> Enum.intersperse("\n")
    |> IO.write
    IO.write("\n")
  end

  defp draw_row(row, col_range) do
    row = Enum.map(row, fn {{col, _row}, color} -> {col, color} end)
    |> Map.new

    col_range
    |> Enum.map(fn col ->
      case Map.get(row, col, 0) do
	0 -> ?\s
	1 -> ?\*
      end
    end)
  end

  defp vec_add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
end
