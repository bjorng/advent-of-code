defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part 1 with example" do
    assert Day23.part1(example()) == 3
  end

  test "part 1 with my input data" do
    assert Day23.part1(input()) == 11514
  end

  test "part 2 with my input data" do
    assert Day23.part2(input()) == 479008074
  end

  defp example() do
    """
    cpy 2 a
    tgl a
    tgl a
    tgl a
    cpy 1 a
    dec a
    dec a
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
