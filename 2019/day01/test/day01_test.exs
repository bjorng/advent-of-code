defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "test part 1 with examples" do
    assert Day01.part1(["12"]) == 2
    assert Day01.part1(["14"]) == 2
    assert Day01.part1(["12","14"]) == 4
    assert Day01.part1(["1969"]) == 654
    assert Day01.part1(["100756"]) == 33583
  end

  test "test part 1 with my input" do
    assert Day01.part1(input()) == 3437969
  end

  test "test part 2 with examples" do
    assert Day01.part2(["12"]) == 2
    assert Day01.part2(["14"]) == 2
    assert Day01.part2(["1969"]) == 966
    assert Day01.part2(["100756"]) == 50346
  end

  test "test part 2 with my input" do
    assert Day01.part2(input()) == 5154075
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
  end
end
