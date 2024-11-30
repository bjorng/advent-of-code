defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "part 1 with example" do
    assert Day10.part1(example()) == 4
    assert Day10.part1(example2()) == 8
  end

  test "part 1 with my input data" do
    assert Day10.part1(input()) == 7086
  end

  test "part 2 with example" do
    assert Day10.part2(example3()) == 4
    assert Day10.part2(example4()) == 4
    assert Day10.part2(example5()) == 8
    assert Day10.part2(example6()) == 10
  end

  test "part 2 with my input data" do
    # 221 is too low
    assert Day10.part2(input()) == 317
  end

  defp example() do
    """
    .....
    .S-7.
    .|.|.
    .L-J.
    .....
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    ..F7.
    .FJ|.
    SJ.L7
    |F--J
    LJ...
    """
    |> String.split("\n", trim: true)
  end

  defp example3() do
    """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """
    |> String.split("\n", trim: true)
  end

  defp example4() do
    """
    ..........
    .S------7.
    .|F----7|.
    .||....||.
    .||....||.
    .|L-7F-J|.
    .|..||..|.
    .L--JL--J.
    ..........
    """
    |> String.split("\n", trim: true)
  end

  defp example5() do
    """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """
    |> String.split("\n", trim: true)
  end

  defp example6() do
    """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
