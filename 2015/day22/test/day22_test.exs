defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part 1 with first example" do
    player = %{hit_points: 10, mana: 250}
    boss = %{hit_points: 13, damage: 8}
    spells = ~w(poison magic_missile)a
   assert Day22.play(spells, player, boss) == :player
  end

  test "part 1 with second example" do
    player = %{hit_points: 10, mana: 250}
    boss = %{hit_points: 14, damage: 8}
    spells = ~w(recharge shield drain poison magic_missile)a
    assert Day22.play(spells, player, boss) == :player
  end

  test "part 1 with my input data" do
    assert Day22.part1(boss()) == 953
  end

  test "part 2 with my input data" do
    assert Day22.part2(boss()) == 1289
  end

  defp boss() do
    %{hit_points: 55, damage: 8}
  end
end
