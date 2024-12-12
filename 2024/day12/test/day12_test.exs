defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part 1 with example" do
    assert Day12.part1(small_example()) == 140
    assert Day12.part1(example()) == 1930
  end

  test "part 1 with my input data" do
    assert Day12.part1(input()) == 1486324
  end

  test "part 2 with example" do
    assert Day12.part2(small_example()) == 80
    assert Day12.part2(example()) == 1206
  end

  test "part 2 with my input data" do
#    assert Day12.part2(input()) == nil
  end

  defp example() do
    """
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """
    |> String.split("\n", trim: true)
  end

  defp small_example() do
    """
    AAAA
    BBCD
    BBCC
    EEEC
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
