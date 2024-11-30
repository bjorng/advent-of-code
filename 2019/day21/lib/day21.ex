defmodule Day21 do
  def part1(input) do
    machine = Intcode.new(input)
    commands =
      # I figured out this program in my head while away from my
      # computer. I found out afterwards that the program can be
      # simplified. It is not necessary to use the B sensor at all
      # (and there is no need to test the A sensor twice as I do).
      #
      # (-A + -B + -C) * D + -A
      ['NOT A T',
       'NOT B J',
       'OR J T',
       'NOT C J',
       'OR J T',
       'AND D T',
       'NOT A J',
       'OR T J']
    run_droid(machine, commands, 'WALK')
  end

  def part2(input) do
    machine = Intcode.new(input)
    commands =
      # I did not figure this out by myself. After trying many
      # convoluted expressions for hours, I went to reddit to
      # look for some hint. Unfortunately, I found a spoiler.
      #
      # -A + -(B * C) * D * H
      ['NOT A J',
       'OR B T',
       'AND C T',
       'NOT T T',
       'AND D T',
       'AND H T',
       'OR T J']
    run_droid(machine, commands, 'RUN')
  end

  defp run_droid(machine, commands, do_it) do
    machine = Intcode.execute(machine)
    {output, machine} = Intcode.get_output(machine)
    IO.write output
    commands = Enum.map(commands ++ [do_it], & &1 ++ '\n')
    issue_commands(machine, commands)
  end

  def issue_commands(machine, [cmd | commands]) do
    IO.write cmd
    machine = Intcode.set_input(machine, cmd)
    machine = Intcode.resume(machine)
    {output, machine} = Intcode.get_output(machine)
    case Enum.find(output, & &1 >= 128) do
      nil ->
        IO.write output
        issue_commands(machine, commands)
      result ->
        result
    end
  end
  def issue_commands(_, _), do: nil

end

defmodule Intcode do
  def new(program) do
    machine(program)
  end

  defp machine(input) do
    memory = read_program(input)
    memory = Map.put(memory, :ip, 0)
    Map.put(memory, :output, :queue.new())
  end

  def set_input(memory, input) do
    Map.put(memory, :input, input)
  end

  def get_output(memory) do
    q = Map.fetch!(memory, :output)
    Map.put(memory, :output, :queue.new())
    {:queue.to_list(q), memory}
  end

  def resume(memory) do
    execute(memory, Map.fetch!(memory, :ip))
  end

  def execute(memory, ip \\ 0) do
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
	memory = Map.delete(memory, :ip)
	Map.put(memory, :halted, true)
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
    case Map.get(memory, :input, []) do
      [] ->
	{:suspended, Map.put(memory, :ip, ip)}
      [value | input] ->
        memory = write(memory, out_addr, value)
	Map.put(memory, :input, input)
    end
  end

  defp exec_output(modes, memory, ip) do
    [value] = read_operand_values(memory, ip + 1, modes, 1)
    q = Map.fetch!(memory, :output)
    q = :queue.in(value, q)
    Map.put(memory, :output, q)
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
