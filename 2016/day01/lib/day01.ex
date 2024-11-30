defmodule Day01 do
  def part1(input) do
    parse(input)
    |> Enum.reduce({{0, 0}, 0}, fn command, {location, facing} ->
      case command do
        {:left, amount} ->
          facing = turn_left(facing)
          {move(location, facing, amount), facing}
        {:right, amount} ->
          facing = turn_right(facing)
          {move(location, facing, amount), facing}
      end
    end)
    |> elem(0)
    |> manhattan_distance
  end

  def part2(input) do
    parse(input)
    |> Enum.reduce_while({{0, 0}, 0, MapSet.new()}, fn command, {location, facing, seen} ->
      case command do
        {:left, amount} ->
          facing = turn_left(facing)
          update_part2(location, facing, amount, seen)
        {:right, amount} ->
          facing = turn_right(facing)
          update_part2(location, facing, amount, seen)
      end
    end)
    |> manhattan_distance
  end

  defp update_part2(location, facing, amount, seen) do
    Enum.reduce_while(1..amount, {:cont, {location, facing, seen}},
      fn _, {:cont, {location, facing, seen}} ->
        location = move(location, facing, 1)
        case MapSet.member?(seen, location) do
          true ->
            {:halt, {:halt, location}}
          false ->
            seen = MapSet.put(seen, location)
            {:cont, {:cont, {location, facing, seen}}}
        end
      end)
  end

  defp manhattan_distance({x, y}) do
    abs(x) + abs(y)
  end

  defp turn_left(direction) do
    rem(4 + direction - 1, 4)
  end

  defp turn_right(direction) do
    rem(4 + direction + 1, 4)
  end

  defp move({x, y}, direction, amount) do
    case direction do
      0 -> {x, y + amount}
      2 -> {x, y - amount}
      1 -> {x + amount, y}
      3 -> {x - amount, y}
    end
  end

  defp parse([input]) do
    String.split(input, ", ")
    |> Enum.map(fn <<turn::size(8), amount::binary>> ->
      amount = String.to_integer(amount)
      case turn do
        ?L -> {:left, amount}
        ?R -> {:right, amount}
      end
    end)
  end
end
