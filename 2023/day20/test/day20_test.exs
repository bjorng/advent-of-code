defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part 1 with example" do
    assert Day20.part1(example()) == 32000000
    assert Day20.part1(example2()) == 11687500
  end

  test "part 1 with my input data" do
    assert Day20.part1(input()) == 743090292
  end

  test "part 2 with example" do
#    assert Day20.part2(example()) == nil
  end

  test "part 2 with my input data" do
    assert Day20.part2(input()) == 241528184647003
  end

  defp example() do
    """
    broadcaster -> a, b, c
    %a -> b
    %b -> c
    %c -> inv
    &inv -> a
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
