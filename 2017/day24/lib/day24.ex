defmodule Day24 do
  def part1(input) do
    pairs = parse_input(input)
    build_bridge_1(0, pairs, 0)
  end

  def part2(input) do
    pairs = parse_input(input)
    {_, strength} = build_bridge_2(0, pairs, {0, 0})
    strength
  end

  defp build_bridge_1(port, pairs, strength) do
    {match, no_match} = Enum.split_with(pairs, fn [a, b] ->
      port === a or port === b
    end)
    Enum.map(match, fn pair ->
      [next_port] = pair -- [port]
      next = (match -- [pair]) ++ no_match
      build_bridge_1(next_port, next, strength + Enum.sum(pair))
    end)
    |> Enum.max(&>=/2, fn -> strength end)
  end

  defp build_bridge_2(port, pairs, {len, strength}) do
    {match, no_match} = Enum.split_with(pairs, fn [a, b] ->
      port === a or port === b
    end)
    Enum.map(match, fn pair ->
      [next_port] = pair -- [port]
      next = (match -- [pair]) ++ no_match
      build_bridge_2(next_port, next, {len + 1, strength + Enum.sum(pair)})
    end)
    |> Enum.max(&>=/2, fn -> {len, strength} end)
  end

  defp parse_input(lines) do
    Enum.map(lines, fn line ->
      String.split(line, "/")
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
