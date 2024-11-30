defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "part 1 with example" do
    assert Day07.part1(example()) == 2
  end

  test "part 1 with my input data" do
    assert Day07.part1(input()) == 110
  end

  test "part 2 with example" do
    assert Day07.part2(example2()) == 3
  end

  test "part 2 with my input data" do
    assert Day07.part2(input()) == 242
  end

  defp example() do
    """
    abba[mnop]qrst
    abcd[bddb]xyyx
    aaaa[qwer]tyui
    ioxxoj[asdfgh]zxcvbn
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    aba[bab]xyz
    xyx[xyx]xyx
    aaa[kek]eke
    zazbz[bzb]cdb
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
