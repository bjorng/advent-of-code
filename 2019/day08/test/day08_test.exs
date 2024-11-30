defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "test part 1 with examples" do
    assert Day08.part1("123456789012", 3, 2) == 1
  end

  test "test part 1 with my input" do
    assert Day08.part1(input(), 25, 6) == 2975
  end

  test "test part 2 with examples" do
    assert Day08.part2("0222112222120000", 2, 2) == nil
  end

  test "test part 2 with my input" do
    assert Day08.part2(input(), 25, 6) == nil
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
