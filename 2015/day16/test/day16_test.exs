defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "part 1 with my input data" do
    assert Day16.part1(input(), ticker_tape()) == 40
  end

  test "part 2 with my input data" do
    assert Day16.part2(input(), ticker_tape()) == 241
  end

  defp ticker_tape() do
    """
    children: 3
    cats: 7
    samoyeds: 2
    pomeranians: 3
    akitas: 0
    vizslas: 0
    goldfish: 5
    trees: 3
    cars: 2
    perfumes: 1
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
