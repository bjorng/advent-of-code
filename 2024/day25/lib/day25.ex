defmodule Day25 do
  def part1(input) do
    {keys, locks} = parse(input)
    Enum.flat_map(locks, fn lock ->
      Enum.map(keys, fn key ->
        Enum.zip_with(key, lock, fn a, b -> a + b > 5 end)
        |> Enum.any?(&(&1))
      end)
    end)
    |> Enum.reject(&(&1))
    |> Enum.count
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn block ->
      lock? = match?("#" <> _, block)
      String.split(block, "\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.to_charlist
        |> Enum.map(fn char ->
          if char === ?\#, do: 1, else: 0
        end)
      end)
      |> Enum.zip_reduce([], &[Enum.sum(&1) - 1 | &2])
      |> then(&{lock?, &1})
    end)
    |> then(fn items ->
      %{false: keys, true: locks} =
        Enum.group_by(items, &elem(&1, 0), &elem(&1, 1))
      {keys, locks}
    end)
  end
end
