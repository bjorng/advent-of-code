defmodule Day09 do
  def part1(program, input \\ 1) do
    memory = read_program(program)
    memory = set_input(memory, [input])
    memory = execute(memory)
    read_output(memory)
  end

  def part2(program) do
    memory = read_program(program)
    memory = set_input(memory, [2])
    memory = execute(memory)
    read_output(memory)
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
    input = Map.fetch!(memory, :input)
    memory = Map.put(memory, :input, tl(input))
    write(memory, out_addr, hd(input))
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

  defp set_input(memory, input) do
    Map.put(memory, :input, input)
  end

  defp read_output(memory), do: Enum.reverse(Map.get(memory, :output, []))

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
