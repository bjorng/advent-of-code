defmodule Day12 do
  def part1(input) do
    Interpreter.new(input)
    |> Interpreter.execute
    |> Map.get(:a)
  end

  def part2(input) do
    Interpreter.new(input, 1)
    |> Interpreter.execute
    |> Map.get(:a)
  end
end

defmodule Interpreter do
  def new(program, c \\ 0) do
    machine(program)
    |> Map.put(:c, c)
  end

  defp machine(program) do
    read_program(program)
    |> Map.put(:a, 0)
    |> Map.put(:b, 0)
    |> Map.put(:c, 0)
    |> Map.put(:d, 0)
    |> Map.put(:ip, 0)
  end

  def execute(memory, ip \\ 0) do
    instr = Map.get(memory, ip, :done)
    case instr do
      {:cpy, src, dst} ->
        memory = Map.replace!(memory, dst, get_value(memory, src))
        execute(memory, ip + 1)
      {:inc, dst} ->
        value = Map.fetch!(memory, dst)
        memory = Map.replace!(memory, dst, value + 1)
        execute(memory, ip + 1)
      {:dec, dst} ->
        value = Map.fetch!(memory, dst)
        memory = Map.replace!(memory, dst, value - 1)
        execute(memory, ip + 1)
      {:jnz, src, offset} ->
        case get_value(memory, src) do
          0 -> execute(memory, ip + 1)
          _ -> execute(memory, ip + offset)
        end
      :done ->
        memory
    end
  end

  defp get_value(memory, src) do
    if is_atom(src) do
      Map.fetch!(memory, src)
    else
      src
    end
  end

  defp read_program(input) do
    input
    |> Enum.map(fn instr ->
      [name | args] = String.split(instr, " ")
      args = Enum.map(args, fn arg ->
        case Integer.parse(arg) do
          :error -> String.to_atom(arg)
          {val, ""} -> val
        end
      end)
      List.to_tuple([String.to_atom(name) | args])
    end)
    |> Stream.with_index
    |> Stream.map(fn {code, index} -> {index, code} end)
    |> Map.new
  end
end
