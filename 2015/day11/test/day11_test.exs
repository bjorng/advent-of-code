defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "part 1 with examples" do
    assert Day11.is_valid('hijklmmn') == false
    assert Day11.is_valid('abbceffg') == false
    assert Day11.is_valid('abbcegjk') == false
    assert Day11.is_valid('abbcegpqr') == false
    assert Day11.part1("abcdefgh") == "abcdffaa"
    assert Day11.part1("ghijklmn") == "ghjaabcc"
  end

  test "part 1 with my input data" do
    assert Day11.part1(input()) == "hxbxxyzz"
  end

  test "part 2 with my input data" do
    assert Day11.part2(input()) == "hxcaabcc"
  end

  defp input() do
    "hxbxwxba"
  end
end
