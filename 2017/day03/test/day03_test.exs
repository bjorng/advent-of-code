defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "test part 1 with examples" do
    assert Day03.part1(1) == 0
    assert Day03.part1(12) == 3
    assert Day03.part1(23) == 2
    assert Day03.part1(1024) == 31
  end

  test "test part 1 with my input data" do
    assert Day03.part1(input()) == 552
  end

  test "test part 2 with examples" do
    assert Day03.part2(24) == 25
    assert Day03.part2(805) == 806
  end

  test "test part 2 with my input data" do
    assert Day03.part2(input()) == 330785
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
    |> String.to_integer
  end
end
