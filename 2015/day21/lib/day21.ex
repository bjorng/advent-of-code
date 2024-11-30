defmodule Day21 do
  @weapons [%{cost: 8,  damage: 4},
            %{cost: 10, damage: 5},
            %{cost: 25, damage: 6},
            %{cost: 40, damage: 7},
            %{cost: 74, damage: 8}]

  @armor [%{cost: 13,  armor: 1},
          %{cost: 31,  armor: 2},
          %{cost: 53,  armor: 3},
          %{cost: 75,  armor: 4},
          %{cost: 102, armor: 5}]

  @rings [%{cost: 25, damage: 1},
          %{cost: 50, damage: 2},
          %{cost: 100, damage: 3},
          %{cost: 20, armor: 1},
          %{cost: 40, armor: 2},
          %{cost: 80, armor: 3}]

  def part1(boss) do
    all_combinations()
    |> Enum.map(fn items ->
      item = consolidate(items)
      {Map.fetch!(item, :cost), item}
    end)
    |> Enum.sort
    |> Enum.dedup
    |> Enum.drop_while(fn {_, you} ->
      you = Map.put(you, :hit_points, 100)
      play(you, boss) == :boss end)
    |> Enum.take(1)
    |> hd
    |> elem(0)
  end

  def part2(boss) do
    all_combinations()
    |> Enum.map(fn items ->
      item = consolidate(items)
      {Map.fetch!(item, :cost), item}
    end)
    |> Enum.sort
    |> Enum.dedup
    |> Enum.reverse
    |> Enum.drop_while(fn {_, you} ->
      you = Map.put(you, :hit_points, 100)
      play(you, boss) == :you end)
    |> Enum.take(1)
    |> hd
    |> elem(0)
  end

  def play(you, boss) do
    with {:ok, boss} <- hit(you, boss, :you),
         {:ok, you} <- hit(boss, you, :boss)
      do
      play(you, boss)
    end
  end

  defp consolidate(items) do
    initial = %{cost: 0, damage: 0, armor: 0}
    Enum.reduce(items, initial, fn item, acc ->
      Enum.reduce(item, acc, fn {key, value}, acc ->
        Map.update!(acc, key, &(&1 + value))
      end)
    end)
  end

  defp hit(attacker, defender, winner) do
    %{damage: damage} = attacker
    %{hit_points: points, armor: armor} = defender
    damage = max(damage - armor, 1)
    points = points - damage
    defender = %{defender | hit_points: points}
    if points <= 0 do
      winner
    else
      {:ok, defender}
    end
  end

  defp all_combinations() do
    weapon_armor =
      Enum.flat_map(@weapons, fn weapon ->
        Enum.flat_map(@armor, fn armor ->
          [[weapon, armor]]
        end)
      end)

    combinations =
    Enum.reduce(@weapons, weapon_armor, fn weapon, acc ->
      [[weapon] | acc]
    end)

    Enum.reduce(combinations, combinations, fn combination, acc ->
      Enum.reduce(@rings, acc, fn ring, acc ->
        one_ring = [ring | combination]
        acc = [one_ring | acc]
        Enum.reduce(@rings -- [ring], acc, fn ring, acc ->
          [[ring | one_ring] | acc]
        end)
      end)
    end)
  end
end
