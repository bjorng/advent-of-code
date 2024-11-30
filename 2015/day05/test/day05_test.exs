defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "part 1 with example" do
    assert Day05.part1(example()) == 2
  end

  test "part 1 with my input data" do
    assert Day05.part1(input()) == 255
  end

  test "part 2 with example" do
    assert Day05.part2(example2()) == 2
  end

  test "part 2 with my input data" do
    assert Day05.part2(input()) == 55
  end

  defp example() do
    """
    ugknbfddgicrmopn
    aaa
    jchzalrnumimnmhp
    haegwjzuvuyypxyu
    dvszwmarrgswjxmb
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    qjhvhtzxzqqjkmpb
    xxyxx
    uurcxstgmygtbstg
    ieodomkazucvgmuy
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
