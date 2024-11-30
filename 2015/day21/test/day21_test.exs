defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with example" do
    you = %{hit_points: 8, damage: 5, armor: 5}
    boss = %{hit_points: 12, damage: 7, armor: 2}
    assert Day21.play(you, boss) == :you
  end

  test "part 1 with my input data" do
    assert Day21.part1(boss()) == 121
  end

  test "part 2 with my input data" do
    assert Day21.part2(boss()) == 201
  end

  defp boss() do
    %{hit_points: 103, damage: 9, armor: 2}
  end
end
