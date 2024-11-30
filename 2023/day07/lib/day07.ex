defmodule Day07 do
  def part1(input) do
    parse(input)
    |> result(&type_part1/1)
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn {hand, bid} ->
      {Enum.map(hand,
          fn 11 -> 1
            s -> s
          end), bid}
    end)
    |> result(&type_part2/1)
  end

  defp result(hands, type) do
    hands
    |> Enum.sort_by(fn {hand, _bid} ->
      {type.(hand), hand}
    end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_hand, bid}, rank} -> rank * bid end)
    |> Enum.sum
  end

  defp type_part1(hand) do
    type_part1(Enum.sort(hand), :'0high')
  end

  defp type_part1([s, s, s, s, s], _), do: :'6five'
  defp type_part1([s, s, s, s | _], _), do: :'5four'
  defp type_part1([s, s, s], :'1pair'), do: :'4full'
  defp type_part1([s, s, s | rest], :'0high'), do: type_part1(rest, :'3')
  defp type_part1([s, s | rest], :'0high'), do: type_part1(rest, :'1pair')
  defp type_part1([s, s | rest], :'1pair'), do: type_part1(rest, :'2pair')
  defp type_part1([s, s], :'3'), do: :'4full'
  defp type_part1([_ | rest], type_part1), do: type_part1(rest, type_part1)
  defp type_part1([], type_part1), do: type_part1

  defp type_part2(hand) do
    case Enum.sort(hand) do
      [1 | rest] ->
        Enum.reduce(2..14, :'0high', fn strength, acc ->
          max(acc, type_part2([strength | rest]))
        end)
      hand ->
        type_part1(hand, :'0high')
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ")
      hand = String.to_charlist(hand)
      |> Enum.map(fn strength ->
        if strength in ?0..?9 do
          strength - ?0
        else
          %{?A => 14, ?K => 13, ?Q => 12, ?J => 11, ?T => 10}[strength]
        end
      end)
      {hand, String.to_integer(bid)}
    end)
  end
end
