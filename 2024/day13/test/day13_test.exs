defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "part 1 with example" do
    assert Day13.part1(example()) == 480
  end

  test "part 1 with my input data" do
    assert Day13.part1(input()) == 31065
  end

  test "part 2 with example" do
    assert Day13.part2(example()) == 875318608908
  end

  test "part 2 with my input data" do
    assert Day13.part2(input()) == 93866170395343
  end

  defp example() do
    """
    Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=8400, Y=5400

    Button A: X+26, Y+66
    Button B: X+67, Y+21
    Prize: X=12748, Y=12176

    Button A: X+17, Y+86
    Button B: X+84, Y+37
    Prize: X=7870, Y=6450

    Button A: X+69, Y+23
    Button B: X+27, Y+71
    Prize: X=18641, Y=10279
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
