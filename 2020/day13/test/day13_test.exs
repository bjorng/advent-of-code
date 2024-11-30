defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "part 1 with example" do
    assert Day13.part1(example()) == 295
  end

  test "part 1 with my input data" do
    assert Day13.part1(input()) == 2406
  end

  test "part 2 with example" do
    assert Day13.part2(["0", "17,x,13,19"]) == 3417
    assert Day13.part2(example()) == 1068781
    assert Day13.part2(["0", "67,7,59,61"]) == 754018
    assert Day13.part2(["0", "67,x,7,59,61"]) == 779210
    assert Day13.part2(["0", "67,7,x,59,61"]) == 1261476
    assert Day13.part2(["0", "1789,37,47,1889"]) == 1202161486
  end

  test "part 2 with my input data" do
    assert Day13.part2(input()) == 225850756401039
  end

  defp example() do
    """
    939
    7,13,x,x,59,x,31,19
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
