defmodule Day24Test do
  use ExUnit.Case
  doctest Day24

  test "part one, examples" do
    assert Day24.part1(example1()) == {:infection, 5216}
  end

  test "part one, real input" do
    assert Day24.part1(input()) == {:infection, 21891}
  end

  test "part two, examples" do
    assert Day24.part1(example1(), 1570) == {:immune_system, 51}
    assert Day24.part1(input(), 22) == {:stalemate, {599, 7047}}
    assert Day24.part1(input(), 82) == {:immune_system, 7058}
  end

  test "part two, real data" do
    # The answer is 7058, obtained with boost 82.
    assert Day24.part2(input()) == {7058, 82}
  end

  defp example1 do
    """
    Immune System:
    17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
    989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

    Infection:
    801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
    4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4
    """
    |> String.split("\n", trim: true)
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
