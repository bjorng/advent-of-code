defmodule Day05 do
  def part1(input) do
    memory = read_program(input)
    memory = set_input(memory, 1)
    List.last(execute(memory))
  end

  def part2(program, input) do
    memory = read_program(program)
    memory = set_input(memory, input)
    List.last(execute(memory))
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
	memory = exec_input(memory, ip)
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
      99 ->
	Enum.reverse(Map.get(memory, :output, []))
    end
  end

  defp exec_arith_op(op, modes, memory, ip) do
    [in1, in2] = read_operand_values(memory, ip + 1, modes, 2)
    out_addr = read(memory, ip + 3)
    result = op.(in1, in2)
    write(memory, out_addr, result)
  end

  defp exec_input(memory, ip) do
    out_addr = read(memory, ip + 1)
    write(memory, out_addr, Map.fetch!(memory, :input))
  end

  defp exec_output(modes, memory, ip) do
    [value] = read_operand_values(memory, ip + 1, modes, 1)
    output = Map.get(memory, :output, [])
    output = [value | output]
    Map.put(memory, :output, output)
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
    out_addr = read(memory, ip + 3)
    result = case op.(operand1, operand2) do
	       true -> 1
	       false -> 0
	     end
    write(memory, out_addr, result)
  end

  defp read_operand_values(_memory, _addr, _modes, 0), do: []
  defp read_operand_values(memory, addr, modes, n) do
    operand = read(memory, addr)
    operand = case rem(modes, 10) do
		0 -> read(memory, operand)
		1 -> operand
	      end
    [operand | read_operand_values(memory, addr + 1, div(modes, 10), n - 1)]
  end

  defp fetch_opcode(memory, ip) do
    opcode = read(memory, ip)
    modes = div(opcode, 100)
    opcode = rem(opcode, 100)
    {opcode, modes}
  end

  defp set_input(memory, input) do
    Map.put(memory, :input, input)
  end

  defp read(memory, addr) do
    Map.fetch!(memory, addr)
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
