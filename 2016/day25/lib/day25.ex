defmodule Day25 do
  use Bitwise

  def part1(input) do
    Interpreter.new(input)
    |> Map.put(:out_handler, {&analyse_signal/2, nil})
    |> find_value(0)
  end

  defp find_value(interpreter, value) do
    result = interpreter
    |> Map.put(:a, value)
    |> Interpreter.execute

    case result do
      :ok -> value
      :error -> find_value(interpreter, value + 1)
    end
  end

  defp analyse_signal(value, nil) do
    next = (value + 1) &&& 1
    {:cont, {0, next}}
  end
  defp analyse_signal(_, {64, _}) do
    {:halt, :ok}
  end
  defp analyse_signal(value, {num_bits, value}) do
    next = (value + 1) &&& 1
    {:cont, {num_bits + 1, next}}
  end
  defp analyse_signal(_, _) do
    {:halt, :error}
  end

end

defmodule Interpreter do
  use Bitwise

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
    |> Map.put(:out_handler, {fn _, _ -> {:cont, 0} end, 0})
  end

  def execute(memory), do: execute(memory, 0)

  def execute(memory, ip) do
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
      {:out, src} ->
        value = get_value(memory, src)
        true = value in 0..1
        {f, acc} = Map.fetch!(memory, :out_handler)
        case f.(value, acc) do
          {:cont, acc} ->
            memory = %{memory | out_handler: {f, acc}}
            execute(memory, ip + 1)
          {:halt, return} ->
            return
        end
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
