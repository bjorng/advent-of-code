defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "part 1 with example" do
    assert Day01.part1("(())") == 0
    assert Day01.part1("()()") == 0
    assert Day01.part1("(((") == 3
    assert Day01.part1("(()(()(") == 3
    assert Day01.part1("))(((((") == 3
    assert Day01.part1("())") == -1
    assert Day01.part1("))(") == -1
    assert Day01.part1(")))") == -3
    assert Day01.part1(")())())") == -3
  end

  test "part 1 with my input data" do
    assert Day01.part1(input()) == 74
  end

  test "part 2 with example" do
    assert Day01.part2(")") == 1
    assert Day01.part2("()())") == 5
  end

  test "part 2 with my input data" do
    assert Day01.part2(input()) == 1795
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
