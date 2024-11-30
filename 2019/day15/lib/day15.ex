defmodule Day15 do
  def part1(input) do
    droid = Droid.new(input)
    {_droid, shortest_path} = Droid.find_path(droid)
    shortest_path
  end

  def part2(input) do
    droid = Droid.new(input)
    {oxygen_minutes, _} = Droid.find_path(droid)
    oxygen_minutes
  end
end

defmodule Droid do
  defstruct machine: nil, grid: %{}, pos: {0, 0}, oxygen: nil

  def new(program) do
    machine = Intcode.new(program)
    %Droid{machine: machine}
  end

  def find_path(droid) do
    paths = [[{droid.machine, {0, 0}}]]
    find_path(droid, paths)
  end

  def find_path(droid, paths) do
    {paths, droid} = extend_paths(paths, droid)
    case droid.oxygen do
      {_, _} ->
	draw_grid(droid)
        {fill_oxygen(droid), length(hd(paths)) - 1}
      nil ->
	find_path(droid, paths)
    end
  end

  defp extend_paths([path | paths], droid) do
    {paths1, droid} = extend_path(path, droid)
    {paths2, droid} = extend_paths(paths, droid)
    {paths1 ++ paths2, droid}
  end
  defp extend_paths([], droid), do: {[], droid}

  defp extend_path([{machine, pos} | _] = path, droid) do
    Enum.reduce(directions(), {[], droid}, fn dir, {acc, droid} ->
      case try_dir(machine, pos, dir, droid) do
	{[], droid} -> {acc, droid}
	{new, droid} -> {[new ++ path | acc], droid}
      end
    end)
  end

  defp try_dir(machine, pos, dir, droid) do
    grid = droid.grid
    new_pos = vec_add(pos, dir)
    case grid do
      %{^new_pos => :wall} ->
	{[], droid}
      %{^new_pos => :visited} ->
	{[], droid}
      %{} ->
	case move_droid(machine, dir) do
	  {_machine, :wall} ->
	    grid = Map.put(grid, new_pos, :wall)
	    droid = %{droid | grid: grid}
	    {[], droid}
	  {machine, :moved} ->
	    grid = Map.put(grid, new_pos, :visited)
	    droid = %{droid | grid: grid}
	    {[{machine, new_pos}], droid}
	  {machine, :oxygen} ->
	    grid = Map.put(grid, new_pos, :oxygen)
	    droid = %{droid | grid: grid, oxygen: new_pos}
	    {[{machine, new_pos}], droid}
	end
    end
  end

  defp fill_oxygen(droid) do
    fill_oxygen(droid.grid, 0)
  end

  defp fill_oxygen(grid, minutes) do
    oxygen_ps = Enum.reduce(grid, [], fn {pos, type}, acc ->
      case type do
	:oxygen -> [pos | acc]
	_ -> acc
      end
    end)
    new_ps = Enum.flat_map(oxygen_ps, fn pos ->
      Enum.map(directions(), fn dir -> vec_add(pos, dir) end)
      |> Enum.filter(fn pos ->
	case Map.get(grid, pos, :wall) do
	  :oxygen -> false
	  :wall -> false
	  _ -> true
	end
      end)
    end)
    case new_ps do
      [] ->
	minutes
      [_ | _] ->
	grid = Enum.reduce(new_ps, grid, fn pos, acc -> Map.put(acc, pos, :oxygen) end)
	fill_oxygen(grid, minutes + 1)
    end
  end


  defp directions() do
    [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
  end

  defp move_droid(machine, dir) do
    machine = Intcode.set_input(machine, droid_dir(dir))
    machine = Intcode.resume(machine)
    {machine,
     case Intcode.get_output(machine) do
       0 -> :wall
       1 -> :moved
       2 -> :oxygen
     end}
  end

  defp droid_dir({0, 1}), do: 1
  defp droid_dir({0, -1}), do: 2
  defp droid_dir({-1, 0}), do: 3
  defp droid_dir({1, 0}), do: 4

  defp vec_add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  defp draw_grid(droid) do
    IO.write("\n\n")
    grid = Map.put(droid.grid, droid.pos, :droid)
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
      case Map.get(row, col, :empty) do
	:visited -> ?\_
	:empty -> ?\.
	:wall -> ?\#
	:oxygen -> ?\O
	:droid -> ?\D
      end
    end)
  end
end

defmodule Intcode do
  def new(program) do
    machine(program)
  end

  defp machine(input) do
    memory = read_program(input)
    Map.put(memory, :ip, 0)
  end

  def set_input(memory, input) do
    Map.put(memory, :input, [input])
  end

  def get_output(memory) do
    Map.fetch!(memory, :output)
  end

  def resume(memory) do
    memory = Map.delete(memory, :output)
    execute(memory, Map.fetch!(memory, :ip))
  end

  defp execute(memory, ip) do
    {opcode, modes} = fetch_opcode(memory, ip)
    case opcode do
      1 ->
	memory = exec_arith_op(&+/2, modes, memory, ip)
	execute(memory, ip + 4)
      2 ->
	memory = exec_arith_op(&*/2, modes, memory, ip)
	execute(memory, ip + 4)
      3 ->
	case exec_input(modes, memory, ip) do
	  {:suspended, memory} ->
	    memory
	  memory ->
	    execute(memory, ip + 2)
	end
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
    case Map.get(memory, :input) do
      [] ->
	{:suspended, Map.put(memory, :ip, ip)}
      [value | input] ->
        memory = write(memory, out_addr, value)
	Map.put(memory, :input, input)
    end
  end

  defp exec_output(modes, memory, ip) do
    [value] = read_operand_values(memory, ip + 1, modes, 1)
    Map.put(memory, :output, value)
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
