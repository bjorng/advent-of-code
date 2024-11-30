defmodule Day15Test do
  use ExUnit.Case
  doctest Day15

  test "part one, example" do
    assert Day15.part1(example1()) == {47, 590, 27730}
    assert Day15.part1(example2()) == {37, 982, 36334}
    assert Day15.part1(example3()) == {46, 859, 39514}
    assert Day15.part1(example4()) == {35, 793, 27755}
    assert Day15.part1(example5()) == {54, 536, 28944}
    assert Day15.part1(example6()) == {20, 937, 18740}
  end

  test "part one, real data" do
    assert Day15.part1(input()) == {107, 2342, 250594}
  end

  test "part two example" do
    assert Day15.part2(example1()) == {29, 172, 4988}
    assert Day15.part2(example3()) == {33, 948, 31284}
    assert Day15.part2(example4()) == {37, 94, 3478}
    assert Day15.part2(example6()) == {30, 38, 1140}
    assert Day15.part2(example5()) == {39, 166, 6474}
  end

  test "part two real data" do
    assert Day15.part2(input()) == {37, 1409, 52133}
  end

  defp example1() do
    """
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
    """
    |> String.trim
    |> String.split("\n")
  end

  defp example2() do
    """
    #######
    #G..#E#
    #E#E.E#
    #G.##.#
    #...#E#
    #...E.#
    #######
    """
    |> String.trim
    |> String.split("\n")
  end

  defp example3() do
    """
    #######
    #E..EG#
    #.#G.E#
    #E.##E#
    #G..#.#
    #..E#.#
    #######
    """
    |> String.trim
    |> String.split("\n")
  end

  defp example4() do
    """
    #######
    #E.G#.#
    #.#G..#
    #G.#.G#
    #G..#.#
    #...E.#
    #######
    """
    |> String.trim
    |> String.split("\n")
  end

  defp example5() do
    """
    #######
    #.E...#
    #.#..G#
    #.###.#
    #E#G#G#
    #...#G#
    #######
    """
    |> String.trim
    |> String.split("\n")
  end

  defp example6() do
    """
    #########
    #G......#
    #.E.#...#
    #..##..G#
    #...##..#
    #...#...#
    #.G...G.#
    #.....G.#
    #########
    """
    |> String.trim
    |> String.split("\n")
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
