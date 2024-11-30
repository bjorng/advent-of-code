defmodule Day23 do
  def part1(input) do
    Interpreter.new(input)
    |> Map.put(:a, 7)
    |> Interpreter.execute
    |> Map.get(:a)
  end

  def part2(input) do
    Interpreter.new(input)
    |> Map.put(:a, 12)
    |> Interpreter.optimize
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

  def optimize(memory) do
    case memory do
      %{4 => {:cpy, r2, r3},
        5 => {:inc, r1},
        6 => {:dec, r3},
        7 => {:jnz, r3, -2},
        8 => {:dec, r4},
        9 => {:jnz, r4, -5}} ->
        case Enum.uniq([r1, r2, r3, r4]) |> Enum.count do
          4 ->
            Map.replace!(memory, 5, {:patched, mul_patch_fn(r1, r3, r4)})
          _ ->
            memory
        end
      %{} ->
        memory
    end
  end

  defp mul_patch_fn(r1, r3, r4) do
    fn memory ->
      %{^r1 => val1, ^r3 => val3, ^r4 => val4} = memory
      val1 = val1 + val3 * val4
      memory = %{memory | r1 => val1, r3 => 0, r4 => 0}
      execute(memory, 10)
    end
  end

  def execute(memory, ip \\ 0) do
    instr = Map.get(memory, ip, :done)
    case instr do
      {:cpy, src, dst} when is_atom(dst) ->
        memory = Map.replace!(memory, dst, get_value(memory, src))
        execute(memory, ip + 1)
      {:cpy, _src, dst} when is_integer(dst) ->
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
          _ -> execute(memory, ip + get_value(memory, offset))
        end
      {:tgl, src} ->
        address = ip + get_value(memory, src)
        memory = toggle(memory, address)
        execute(memory, ip + 1)
      {:patched, f} ->
        f.(memory)
      :done ->
        memory
    end
  end

  defp toggle(memory, address) do
    case memory do
      %{^address => instr} ->
        instr = toggle_instr(instr)
        Map.replace!(memory, address, instr)
      %{} ->
        memory
    end
  end

  defp toggle_instr(instr) do
    case instr do
      {:inc, dst} ->
        {:dec, dst}
      {_, arg} ->
        {:inc, arg}
      {:jnz, arg1, arg2} ->
        {:cpy, arg1, arg2}
      {_, arg1, arg2} ->
        {:jnz, arg1, arg2}
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
