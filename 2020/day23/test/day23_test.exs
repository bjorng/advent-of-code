defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part 1 with example" do
    assert Day23.part1(example(), 10) == 92658374
    assert Day23.part1(example()) == 67384529
  end

  test "part 1 with my input data" do
   assert Day23.part1(input()) == 25468379
  end

  test "part 2 with example" do
    #assert Day23.part2(example()) == 149245887792
  end

  test "part 2 with my input data" do
    assert Day23.part2(input()) == 474747880250
  end

  defp example(), do: 389125467

  defp input(), do: 193467258
end
