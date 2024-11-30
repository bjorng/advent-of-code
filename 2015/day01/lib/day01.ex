defmodule Day01 do
  def part1(input) do
    input
    |> String.to_charlist
    |> Enum.reduce(0, fn direction, floor ->
      case direction do
        ?( -> floor + 1
        ?) -> floor - 1
      end
    end)
  end

  def part2(input) do
    input
    |> String.to_charlist
    |> Enum.with_index(1)
    |> Enum.reduce_while(0, fn {direction, index}, floor ->
      floor = case direction do
                ?( -> floor + 1
                ?) -> floor - 1
              end
      if floor === -1 do
        {:halt, index}
      else
        {:cont, floor}
      end
    end)
  end
end
