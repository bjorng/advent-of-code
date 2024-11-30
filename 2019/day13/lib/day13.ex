defmodule Day13 do
  # Use "mix animate" to show an animation of the game being played.
  def animate() do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
    |> part2(true)
  end

  def part1(program) do
    machine = Intcode.new(program)
    bot = PlayBot.new(machine)
    Intcode.set_sink(machine, bot)
    send(bot, :go)
    Intcode.go(machine)
    receive do
      {:halted, ^machine} ->
	Intcode.terminate(machine)
	PlayBot.finish(bot).grid
	|> Map.values
	|> Stream.filter(fn id -> id === :block end)
	|> Enum.count
    end
  end

  def part2(program, animate \\ false) do
    machine = Intcode.new(program)
    Intcode.write_memory(machine, 0, 2)
    bot = PlayBot.new(machine, animate)
    Intcode.set_sink(machine, bot)
    send(bot, :go)
    Intcode.go(machine)
    receive do
      {:halted, ^machine} ->
	Intcode.terminate(machine)
	PlayBot.finish(bot).score
    end
  end
end

defmodule PlayBot do
  defstruct grid: %{}, joystick: 0, score: 0, machine: nil,
    ball_pos: {0, 0}, paddle_pos: {0, 0}, animate: false

  def new(machine, animate \\ false) do
    spawn(fn -> play(machine, animate) end)
  end

  def finish(bot) do
    send(bot, :done)
    send(bot, self())
    send(bot, :ignore)
    receive do
      play_bot ->
	play_bot
    end
  end

  defp play(machine, animate) do
    bot = %PlayBot{machine: machine, animate: animate}
    receive do
      :go ->
	if bot.animate do
	  IO.write(IO.ANSI.clear())
	end
	play_loop(bot)
    end
  end

  defp play_loop(bot) do
    case get_command() do
      {:score, score} ->
	bot = %PlayBot{bot | score: score}
	play_loop(bot)
      {:done, pid} ->
	send(pid, bot)
      {:draw, pos, id} ->
	grid = Map.put(bot.grid, pos, id)
	bot = %PlayBot{bot | grid: grid}
	case id do
	  :paddle ->
	    bot = %PlayBot{bot | paddle_pos: pos}
	    play_loop(bot)
	  :ball ->
	    bot = update_ball_pos(bot, pos)
	    bot = adjust_joystick(bot)
	    send_joystick_pos(bot)
	    maybe_animate(bot)
	    play_loop(bot)
	  _ ->
	    play_loop(bot)
	end
    end
  end

  defp update_ball_pos(bot, pos) do
    %PlayBot{bot | ball_pos: pos}
  end

  defp adjust_joystick(bot) do
    %PlayBot{ball_pos: {x, _y}, paddle_pos: {xp, _}} = bot
    j = cond do
      xp > x -> -1
      x > xp -> 1
      true -> 0
    end
    %PlayBot{bot | joystick: j}
  end

  defp send_joystick_pos(bot) do
    send(bot.machine, bot.joystick)
  end

  defp get_command() do
    receive do
      x ->
	receive do
	  y ->
	    receive do
	      z ->
		case {x, y, z} do
		  {:done, pid, _} -> {:done, pid}
		  {-1, 0, score} -> {:score, score}
		  {_, _, id} ->
		    {:draw, {x, y},
		     case id do
		      0 -> :empty
		      1 -> :wall
		      2 -> :block
		      3 -> :paddle
		      4 -> :ball
		    end}
		end
	    end
	end
    end
  end

  defp maybe_animate(bot) do
    if bot.animate do
      draw_grid(bot)
    end
  end

  defp draw_grid(bot) do
    IO.write(IO.ANSI.cursor(0, 0))
    grid = bot.grid
    {{min_col, _}, {max_col, _}} =
      grid
      |> Map.keys
      |> Enum.min_max_by(&(elem(&1, 0)))

    grid
    |> Enum.group_by(fn {{_col, row}, _color} -> row end)
    |> Enum.sort_by(fn {row, _} -> row end)
    |> Enum.map(fn {_, row} -> draw_row(row, min_col..max_col) end)
    |> Enum.intersperse("\n")
    |> IO.write
    IO.write("\n")
    IO.write("SCORE: #{bot.score}\n")
    :timer.sleep(25)
  end

  defp draw_row(row, col_range) do
    row = Enum.map(row, fn {{col, _row}, color} -> {col, color} end)
    |> Map.new

    col_range
    |> Enum.map(fn col ->
      case Map.get(row, col, :empty) do
	:empty -> ?\s
	:wall -> ?\#
	:block -> ?\=
	:paddle -> ?\_
	:ball -> ?\o
      end
    end)
  end
end

defmodule Intcode do
  def new(program) do
    spawn(fn -> machine(program) end)
  end

  def set_sink(machine, sink) do
    send(machine, {:set_sink, sink})
  end

  def write_memory(machine, addr, val) do
    send(machine, {:write_memory, addr, val})
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
      {:write_memory, addr, val} ->
	memory = write(memory, addr, val)
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
