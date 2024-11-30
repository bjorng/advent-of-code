defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "test part 1 with examples" do
    assert Day10.part1(5, example()) == 12
  end

  test "test part 1 with my input data" do
    # 3540 (60 * 59) -- too low
    # 8648 (94 * 92) -- too high
    assert Day10.part1(256, input()) == 3770
  end

  test "test part 2 with examples" do
    assert Day10.part2("") == "a2582a3a0e66e6e86e3812dcb672a272"
    assert Day10.part2("AoC 2017") == "33efeb34ea91902bb2f59c9920caa6cd"
    assert Day10.part2("1,2,3") == "3efbe78a8d82f29979031a4aa0b16a9d"
    assert Day10.part2("1,2,4") == "63960835bcdc130f0b66d7ff4f6a5a8e"
  end

  test "test part 2 with my input data" do
    assert Day10.part2(input()) == "a9d0e68649d0174c8756a59ba21d4dc6"
  end

  defp example() do
    "3,4,1,5"
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
