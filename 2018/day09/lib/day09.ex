defmodule Day09 do
  def part1(input) do
    {players, last_marble} = parse(input)
    solve(players, last_marble)
  end

  def part2(input) do
    {players, last_marble} = parse(input)
    solve(players, 100 * last_marble)
  end

  def solve(players, last_marble) do
    scores =
    for i <- 1..players, into: %{}, do: {i, 0}
    circle = {[], 0, []}
    marble = 1
    acc = {circle, scores}
    Enum.reduce(marble..last_marble, acc, &place_marble/2)
    |> (fn {_, scores} -> scores end).()
    |> (fn scores -> Map.values(scores) end).()
    |> Enum.max
  end

  def place_marble(marble, {circle, scores}) when rem(marble, 23) != 0 do
    circle = place_one marble, circle
    {circle, scores}
  end

  def place_marble(marble, {circle, scores}) do
    player = rem(marble, map_size(scores)) + 1
    circle = ensure_bef circle
    {bef, old_current, aft} = circle
    aft = [old_current | aft]

    {split_off, bef} = Enum.split(bef, 7)
    [taken, current | split_off] = Enum.reverse(split_off)
    aft = split_off ++ aft
    circle = {bef, current, aft}

    score = marble + taken
    scores = Map.update(scores, player, score, &(&1 + score))
    {circle, scores}
  end

  defp place_one marble, circle do
    case circle do
	{[], 0, []} ->
	  {[], marble, [0]}
	{bef, current, [h | aft]} ->
	  {[h, current | bef], marble, aft}
        {bef, current, []} ->
	  [h | aft] = Enum.reverse(bef);
	  {[h, current], marble, aft}
    end
  end

  defp ensure_bef({[_, _, _, _,  _, _, _, _, _ | _], _, _} = circle), do: circle

  defp ensure_bef({bef, current, aft}) do
    {bef ++ Enum.reverse(aft), current, []}
  end

  defp parse([line]) do
    [players, last_marble] =
      Regex.run(~r/^(\d+) players; last marble is worth (\d+) points/,
        line, [capture: :all_but_first])
    {String.to_integer(players), String.to_integer(last_marble)}
  end
end
