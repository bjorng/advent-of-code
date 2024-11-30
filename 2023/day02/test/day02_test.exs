defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "part 1 with example" do
    assert Day02.part1(example()) == 8
  end

  test "part 1 with my input data" do
    assert Day02.part1(input()) == 2505
  end

  test "part 2 with example" do
    assert Day02.part2(example()) == 2286
  end

  test "part 2 with my input data" do
    assert Day02.part2(input()) == 70265
  end

  defp example() do
    """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
