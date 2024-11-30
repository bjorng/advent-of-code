defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "test part 1 with examples" do
    assert Day06.part1(example1()) == 42
  end

  test "test part 1 with my input" do
    assert Day06.part1(input()) == 147807
  end

  test "test part 2 with examples" do
    assert Day06.part2(example2()) == 4
  end

  test "test part 2 with my input" do
    assert Day06.part2(input()) == 229
  end

  defp example1() do
    ["COM)B",
     "B)C",
     "C)D",
     "D)E",
     "E)F",
     "B)G",
     "G)H",
     "D)I",
     "E)J",
     "J)K",
     "K)L"]
  end

  defp example2() do
    ["COM)B",
     "B)C",
     "C)D",
     "D)E",
     "E)F",
     "B)G",
     "G)H",
     "D)I",
     "E)J",
     "J)K",
     "K)L",
     "K)YOU",
     "I)SAN"]
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
  end

end
