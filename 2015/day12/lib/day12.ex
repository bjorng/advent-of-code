defmodule Day12 do
  def part1([input]) do
    Regex.scan(~r/(-?\d+)/, input, [capture: :all_but_first])
    |> List.flatten
    |> Enum.reduce(0, fn number, sum ->
      sum + String.to_integer(number)
    end)
  end

  def part2([input]) do
    Jason.decode!(input)
    |> sum(0)
  end

  defp sum(item, sum) do
    case item do
      [head | tail] when is_integer(head) ->
        sum(tail, sum + head)
      [head | tail] when is_binary(head) ->
        sum(tail, sum)
      [head | tail] ->
        sum(tail, sum(head, sum))
      [] ->
        sum
      map when is_map(map) ->
        values = Map.values(map)
        case Enum.any?(values, &(&1 == "red")) do
          true ->
            sum
          false ->
            sum(values, sum)
        end
    end
  end
end
