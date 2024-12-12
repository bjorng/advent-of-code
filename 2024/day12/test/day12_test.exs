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
    assert Day12.part2(e_shaped()) == 236
    assert Day12.part2(overlapping()) == 436
    assert Day12.part2(example()) == 1206
    assert Day12.part2(overlapping1()) == 368
    assert Day12.part2(overlapping2()) == 4 * 9 + 8 * 16
    assert Day12.part2(overlapping3()) == 8 * 10 + 12 * 15
  end

  test "part 2 with my input data" do
    # 879304 is too low
    # 919546 is too high
    assert Day12.part2(input()) == nil
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

  defp overlapping() do
    """
    OOOOO
    OXOXO
    OOOOO
    OXOXO
    OOOOO
    """
    |> String.split("\n", trim: true)
  end

  defp e_shaped() do
    """
    EEEEE
    EXXXX
    EEEEE
    EXXXX
    EEEEE
    """
    |> String.split("\n", trim: true)
  end

  defp overlapping1() do
    """
    AAAAAA
    AAABBA
    AAABBA
    ABBAAA
    ABBAAA
    AAAAAA
    """
    |> String.split("\n", trim: true)
  end

  defp overlapping2() do
    """
    OOOOO
    OXXXO
    OXXXO
    OXXXO
    OOOOO
    """
    |> String.split("\n", trim: true)
  end

  defp overlapping3() do
    """
    OOOOO
    OXXXO
    XXXXO
    OXXXO
    OOOOO
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
