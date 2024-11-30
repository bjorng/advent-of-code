defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "part 1 with example" do
    assert Day03.part1(">") == 2
    assert Day03.part1("^>v<") == 4
    assert Day03.part1("^v^v^v^v^v") == 2
  end

  test "part 1 with my input data" do
    assert Day03.part1(input()) == 2592
  end

  test "part 2 with example" do
    assert Day03.part2(">v") == 3
    assert Day03.part2("^>v<") == 3
    assert Day03.part2("^v^v^v^v^v") == 11
  end

  test "part 2 with my input data" do
    assert Day03.part2(input()) == 2360
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
