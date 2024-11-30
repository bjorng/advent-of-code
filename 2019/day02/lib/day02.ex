defmodule Day02 do
  def part1(input) do
    memory = read_program(input)
    memory = Map.merge(memory, %{1 => 12, 2 => 2})
    execute(memory)
  end

  def part2(input) do
    memory = read_program(input)
    all = for noun <- 0..99,
      verb <- 0..99 do
      {execute(Map.merge(memory, %{1 => noun, 2 => verb})), noun * 100 + verb}
    end
    {_, answer} = all
    |> Enum.filter(fn {result, _} -> result === 19690720 end)
    |> hd
    answer
  end

  defp execute(memory, ip \\ 0) do
    case Map.fetch!(memory, ip) do
      1 ->
	memory = exec_arith_op(&+/2, memory, ip)
	execute(memory, ip + 4)
      2 ->
	memory = exec_arith_op(&*/2, memory, ip)
	execute(memory, ip + 4)
      99 ->
	Map.fetch!(memory, 0)
    end
  end

  defp exec_arith_op(op, memory, ip) do
    in_addr1 = ip + 1
    in_addr2 = ip + 2
    out_addr = ip + 3
    %{^in_addr1 => in1, ^in_addr2 => in2, ^out_addr => out} = memory
    result = op.(Map.fetch!(memory, in1), Map.fetch!(memory, in2))
    Map.put(memory, out, result)
  end

  defp read_program(input) do
    String.split(input, ",")
    |> Stream.map(fn str ->
      {int, ""} = Integer.parse(str)
      int
    end)
    |> Stream.with_index
    |> Stream.map(fn {code, index} -> {index, code} end)
    |> Map.new
  end
end
