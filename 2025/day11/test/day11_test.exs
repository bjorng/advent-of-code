defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "part 1 with example" do
    assert Day11.part1(example()) == 5
  end

  test "part 1 with my input data" do
    assert Day11.part1(input()) == 607
  end

  test "part 2 with example" do
    assert Day11.part2(example2()) == 2
  end

  test "part 2 with my input data" do
    assert Day11.part2(input()) == 506264456238938
  end

  defp example() do
    """
    aaa: you hhh
    you: bbb ccc
    bbb: ddd eee
    ccc: ddd eee fff
    ddd: ggg
    eee: out
    fff: out
    ggg: out
    hhh: ccc fff iii
    iii: out
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    svr: aaa bbb
    aaa: fft
    fft: ccc
    bbb: tty
    tty: ccc
    ccc: ddd eee
    ddd: hub
    hub: fff
    eee: dac
    dac: fff
    fff: ggg hhh
    ggg: out
    hhh: out
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
