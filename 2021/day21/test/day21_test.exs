defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with example" do
    assert Day21.part1(example()) == 739785
  end

  test "part 1 with my input data" do
    assert Day21.part1(input()) == 752745
  end

  test "part 2 with example" do
    assert Day21.part2(example()) == 444356092776315
  end

  test "part 2 with my input data" do
    assert Day21.part2(input()) == 309196008717909
  end

  defp example() do
    """
    Player 1 starting position: 4
    Player 2 starting position: 8
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
