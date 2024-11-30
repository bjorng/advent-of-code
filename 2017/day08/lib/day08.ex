defmodule Day08 do
  def part1(lines) do
    execution_stream(lines)
    |> Enum.find(fn {instructions, _vars} -> instructions == [] end)
    |> (fn {[], vars} -> vars end).()
    |> Map.values
    |> Enum.max
  end

  def part2(lines) do
    execution_stream(lines)
    |> Enum.reduce_while(0, fn {instructions, vars}, acc ->
      {_, max} = Enum.max_by(vars, fn {_, val} -> val end,
      fn -> {nil, 0} end)
      acc = max(acc, max)
      case instructions do
        [] ->
          {:halt, acc}
        [_ | _] ->
          {:cont, acc}
      end
    end)
  end

  defp execution_stream(lines) do
    program = parse_input(lines)
    Stream.iterate({program, %{}}, fn
      {[f | t], vars} ->
        {t, f.(vars)}
      {[], vars} ->
        {[], vars}
    end)
  end

  defp parse_input(lines) do
    lines
    |> Stream.map(&tokenize/1)
    |> Stream.map(&parse/1)
    |> Enum.to_list
  end

  defp parse([var: var,
              keyword: inc_or_dec,
              integer: offset,
              keyword: :if,
              var: if_var,
              operator: op,
              integer: if_val]) do
    inc_dec = inc_or_dec_fn(inc_or_dec, offset)
    fn vars ->
      if_var = Map.get(vars, if_var, 0)
      if apply(Kernel, op, [if_var, if_val]) do
        val = Map.get(vars, var, 0)
        Map.put(vars, var, inc_dec.(val))
      else
        vars
      end
    end
  end

  defp inc_or_dec_fn(:dec, offset), do: & &1 - offset
  defp inc_or_dec_fn(:inc, offset), do: & &1 + offset

  defp tokenize(" " <> rest) do
    tokenize(rest)
  end

  defp tokenize(">=" <> rest) do
    [{:operator, :>=} | tokenize(rest)]
  end

  defp tokenize(">" <> rest) do
    [{:operator, :>} | tokenize(rest)]
  end

  defp tokenize("<=" <> rest) do
    [{:operator, :<=} | tokenize(rest)]
  end

  defp tokenize("<" <> rest) do
    [{:operator, :<} | tokenize(rest)]
  end

  defp tokenize("!=" <> rest) do
    [{:operator, :!=} | tokenize(rest)]
  end

  defp tokenize("==" <> rest) do
    [{:operator, :==} | tokenize(rest)]
  end

  defp tokenize("-" <> rest) do
    {{:integer, integer}, rest} = get_integer(rest, 0)
    [{:integer, - integer} | tokenize(rest)]
  end

  defp tokenize(<<c, rest::binary>>) when ?a <= c and c <= ?z do
    {token, rest} = get_alpha(rest, [c])
    [token | tokenize(rest)]
  end

  defp tokenize(<<d, rest::binary>>) when ?0 <= d and d <= ?9 do
    {token, rest} = get_integer(rest, d - ?0)
    [token | tokenize(rest)]
  end

  defp tokenize(<<>>), do: []

  defp get_alpha(<<c, rest::binary>>, acc) when ?a <= c and c <= ?z do
    get_alpha(rest, [c | acc])
  end

  defp get_alpha(rest, acc) do
    {case List.to_string(Enum.reverse(acc)) do
       "dec" -> {:keyword, :dec}
       "inc" -> {:keyword, :inc}
       "if" -> {:keyword, :if}
       var -> {:var, var}
     end, rest}
  end

  defp get_integer(<<d, rest::binary>>, acc) when ?0 <= d and d <= ?9 do
    get_integer(rest, acc * 10 + d - ?0)
  end

  defp get_integer(rest, acc), do: {{:integer, acc}, rest}
end
