defmodule Day02 do
  def part1(input) do
    bag = %{red: 12, green: 13, blue: 14}
    parse(input)
    |> Enum.reject(fn {_, subsets} ->
      List.flatten(subsets)
      |> Enum.any?(fn {n, color} ->
        n > bag[color]
      end)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn {_, subsets} ->
      map = %{red: 0, green: 0, blue: 0}
      subsets
      |> List.flatten
      |> Enum.reduce(map, fn {n, color}, map ->
        %{map | color => max(n, map[color])}
      end)
    end)
    |> Enum.map(fn map ->
        Map.values(map) |> Enum.product
    end)
    |> Enum.sum
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      {:ok, [result], "", _, _, _} = GameParser.game(line)
      result
    end)
  end
end

defmodule GameParser do
  import NimbleParsec

  defp atomify([string]), do: String.to_atom(string)

  spaces = ignore(ascii_string([?\s,?\n], min: 1))

  color =
    choice([string("red"), string("green"), string("blue")])
    |> reduce({:atomify, []})

  cube = integer(min: 1)
  |> concat(spaces)
  |> concat(color)
  |> optional(ignore(string(", ")))
  |> reduce({List, :to_tuple, []})

  cubes = times(cube, min: 1)
  |> optional(ignore(string("; ")))
  |> wrap

  subsets = repeat(cubes)
  |> wrap

  game = ignore(string("Game"))
  |> concat(spaces)
  |> integer(min: 1)
  |> ignore(string(":"))
  |> concat(spaces)
  |> concat(subsets)
  |> reduce({List, :to_tuple, []})

  defparsec :game, game
end
