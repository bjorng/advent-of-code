defmodule Day06 do
  def solve(input) do
    parse(input)
    |> Stream.iterate(& cycle_banks(&1))
    |> Stream.with_index
    |> Enum.reduce_while(%{}, fn {banks, cycles}, seen ->
      case seen do
        %{^banks => seen_at} ->
          {:halt, {cycles, cycles - seen_at}}
        %{} ->
          {:cont, Map.put(seen, banks, cycles)}
      end
    end)
  end

  defp cycle_banks(banks) do
    length = length(banks)
    max = Enum.max(banks)
    index = Enum.find_index(banks, & &1 == max)
    cur = length - index
    each = div(max, length)
    rem = rem(max, length)

    {banks, _} = Enum.map_reduce(banks, cur, fn blocks, cur ->
      cond do
        cur == length ->
          {each, 1}
        cur <= rem ->
          {blocks + each + 1, cur + 1}
        true ->
          {blocks + each, cur + 1}
      end
    end)

    banks
  end

  defp parse(string) do
    string
    |> String.split([" ", "\t"])
    |> Enum.map(&String.to_integer/1)
  end

end
