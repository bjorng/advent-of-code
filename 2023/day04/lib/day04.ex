defmodule Day04 do
  def part1(input) do
    parse(input)
    |> Enum.map(fn card ->
      Bitwise.bsl(1, num_winning(card) - 1)
    end)
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn card ->
      {1, num_winning(card)}
    end)
    |> eval_cards
    |> Enum.sum
  end

  defp eval_cards([]), do: []
  defp eval_cards([{copies, wins} | cards]) do
    cards = make_copies(wins, copies, cards)
    [copies | eval_cards(cards)]
  end

  defp make_copies(0, _extra, cards), do: cards
  defp make_copies(_, _extra, []), do: []
  defp make_copies(n, extra, [{copies, wins} | cards]) do
    [{copies + extra, wins} | make_copies(n - 1, extra, cards)]
  end

  defp num_winning({winning, my}) do
    winning = :ordsets.from_list(winning)
    my = :ordsets.from_list(my)
    length(:ordsets.intersection(winning, my))
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      ["Card", _ | list] = String.split(line)
      {winning, ["|" | my]} = Enum.split_while(list, &(&1 != "|"))
      winning = Enum.map(winning, &String.to_integer/1)
      my = Enum.map(my, &String.to_integer/1)
      {winning, my}
    end)
  end
end
