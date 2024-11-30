defmodule Day02 do
  def part1(input) do
    input
    |> parse
    |> Enum.reduce({0, 0}, fn command, {position, depth} ->
      case command do
        {:forward, amount} ->
          {position + amount, depth}
        {:down, amount} ->
          {position, depth + amount}
        {:up, amount} ->
          {position, depth - amount}
      end
    end)
    |> result
  end

  def part2(input) do
    input
    |> parse
    |> Enum.reduce({0, 0, 0}, fn command, {position, depth, aim} ->
      case command do
        {:forward, amount} ->
          {position + amount, depth + aim * amount, aim}
        {:down, amount} ->
          {position, depth, aim + amount}
        {:up, amount} ->
          {position, depth, aim - amount}
      end
    end)
    |> result
  end

  defp result({position, depth}), do: position * depth
  defp result({position, depth, _aim}), do: position * depth

  defp parse(input) do
    Enum.map(input, fn line ->
      case line do
        "forward " <> rest ->
          {:forward, String.to_integer(rest)}
        "down " <> rest ->
          {:down, String.to_integer(rest)}
        "up " <> rest ->
          {:up, String.to_integer(rest)}
      end
    end)
  end
end
