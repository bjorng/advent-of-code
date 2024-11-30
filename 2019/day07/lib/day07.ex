defmodule Day07 do
  def part1(input) do
    program = read_program(input)
    permutations(0, 4)
    |> Stream.filter(&are_unique_phases/1)
    |> Stream.map(fn phases -> run_amplifiers(phases, program) end)
    |> Enum.max
  end

  def part2(input) do
    program = read_program(input)
    permutations(5, 9)
    |> Stream.filter(&are_unique_phases/1)
    |> Stream.map(fn phases -> run_feedback_loop(phases, program) end)
    |> Enum.max
  end

  defp permutations(min, max) do
    n = max - min + 1
    permutations(min..max, n, [])
    |> Stream.chunk_every(n)
  end

  defp permutations(_range, 0, prefix), do: prefix
  defp permutations(range, iters, prefix) do
    range
    |> Stream.flat_map(fn elem ->
      prefix = [elem | prefix]
      permutations(range, iters - 1, prefix)
    end)
  end

  defp are_unique_phases(phases) do
    length(phases) === length(Enum.uniq(phases))
  end

  defp run_amplifiers(phases, memory) do
    Enum.reduce(phases, 0, fn phase, thrust ->
      memory = set_input(memory, [phase, thrust])
      memory = execute(memory)
      [output] = read_output(memory)
      output
    end)
  end

  defp run_feedback_loop(phases, memory) do
    zipped = Enum.zip(phases, List.duplicate(memory, length(phases)))
    {memories, thrust} = run_first_loop(zipped, 0, [])
    run_loops(memories, thrust)
  end

  defp run_first_loop([{phase, memory} | tail], thrust, acc) do
    memory = set_input(memory, [phase, thrust])
    memory = execute(memory)
    [thrust] = read_output(memory)
    memory = reset_output(memory)
    run_first_loop(tail, thrust, [memory | acc])
  end
  defp run_first_loop([], thrust, acc) do
    {Enum.reverse(acc), thrust}
  end

  defp run_loops(memories, thrust) do
    case run_one_loop(memories, thrust, []) do
      {memories, thrust} -> run_loops(memories, thrust)
      :done -> thrust
    end
  end

  defp run_one_loop([memory | memories], thrust, acc) do
    memory = set_input(memory, [thrust])
    memory = resume(memory)
    case read_output(memory) do
      [thrust] ->
	memory = reset_output(memory)
	run_one_loop(memories, thrust, [memory | acc])
      [] ->
	run_one_loop(memories, thrust, :done)
    end
  end
  defp run_one_loop([], _thrust, :done), do: :done
  defp run_one_loop([], thrust, acc) do
    {Enum.reverse(acc), thrust}
  end

  defp resume(memory) do
    execute(memory, Map.fetch!(memory, :ip))
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
	Map.put(memory, :ip, ip + 2)
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
	Map.delete(memory, :ip)
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

  defp read_output(memory), do: Map.get(memory, :output, [])

  defp reset_output(memory), do: Map.put(memory, :output, [])

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
