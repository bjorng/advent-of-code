defmodule Day08 do
  def part1(input) do
    Interpreter.new(input)
    |> Interpreter.set_break_mode
    |> Interpreter.execute
    |> Map.get(:acc)
  end

  def part2(input) do
    Interpreter.new(input)
    |> Interpreter.repair
  end
end

defmodule Interpreter do
  def new(program) do
    machine(program)
  end

  defp machine(program) do
    memory = read_program(program)
    size = map_size(memory)
    memory
    |> Map.put(:size, size)
    |> Map.put(size, :done)
    |> Map.put(:ip, 0)
    |> Map.put(:acc, 0)
    |> Map.put(:break, false)
  end

  def repair(memory) do
    memory = set_break_mode(memory)
    0..Map.get(memory, :size)
    |> Enum.find_value(fn address ->
      instr = case Map.get(memory, address) do
                {:nop, offset} -> {:jmp, offset}
                {:jmp, offset} -> {:nop, offset}
                other -> other
              end
      Map.put(memory, address, instr)
      |> execute
      |> Map.get(:result)
    end)
  end

  def set_break_mode(memory) do
    Map.put(memory, :break, true)
  end

  def execute(memory, ip \\ 0) do
    instr = Map.get(memory, ip)
    memory = case Map.get(memory, :break) do
               true -> Map.put(memory, ip, {:break, instr})
               false -> memory
             end
    case instr do
      {:acc, arg} ->
        memory = Map.update!(memory, :acc, &(&1 + arg))
        execute(memory, ip + 1)
      {:jmp, offset} ->
        execute(memory, ip + offset)
      {:nop, _} ->
        execute(memory, ip + 1)
      :done ->
        Map.put(memory, :ip, ip)
        |> Map.put(:result, Map.get(memory, :acc))
      {:break, _} ->
        Map.put(memory, :ip, ip)
        |> Map.put(:result, nil)
    end
  end

  defp read_program(input) do
    input
    |> Enum.map(fn instr ->
      [name, arg] = String.split(instr, " ")
      {String.to_atom(name), String.to_integer(arg)}
    end)
    |> Stream.with_index
    |> Stream.map(fn {code, index} -> {index, code} end)
    |> Map.new
  end
end
