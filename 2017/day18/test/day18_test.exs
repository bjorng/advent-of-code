defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with examples" do
    input = """
    set a 1
    add a 2
    mul a a
    mod a 5
    snd a
    set a 0
    rcv a
    jgz a -1
    set a 1
    jgz a -2
    """
    |> String.split("\n", trim: true)
    assert Day18.part1(input) == 4
  end

  test "part 1 with my input" do
    assert Day18.part1(input()) == 7071
  end

  test "part 2 with examples" do
    input = """
    snd 1
    snd 2
    snd p
    rcv a
    rcv b
    rcv c
    rcv d
    """
    |> String.split("\n", trim: true)
    assert Day18.part2(input) == 3
  end

  test "part 2 with my input" do
    assert Day18.part2(input()) == 8001
  end

  defp input do
    File.read!('input.txt')
    |> String.split("\n", trim: true)
  end
end
