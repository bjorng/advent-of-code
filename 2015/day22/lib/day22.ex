defmodule Day22 do
  def part1(boss) do
    solve(boss, false)
  end

  def part2(boss) do
    solve(boss, true)
  end

  def play(spells, player, boss) do
    {player, boss} = init(player, boss)
    do_play(spells, player, boss)
  end

  defp solve(boss, hard) do
    player = %{hit_points: 50, mana: 500}
    {player, boss} = init(player, boss)
    possible_spells(player)
    |> Enum.map(fn spell ->
      {cost(spell), {spell, player, boss}}
    end)
    |> :gb_sets.from_list
    |> solve(:infinity, hard)
  end

  defp solve(q, best, hard) do
    {element, q} = :gb_sets.take_smallest(q)
    case element do
      {smallest, _} when smallest >= best ->
        best
      {cost, {spell, player, boss}} ->
        case play_round(player, spell, boss, hard) do
          :player ->
            solve(q, cost, hard)
          :boss ->
            solve(q, best, hard)
          {player, boss} ->
            q = possible_spells(player)
            |> Enum.reduce(q, fn spell, acc ->
              element = {cost + cost(spell), {spell, player, boss}}
              :gb_sets.add(element, acc)
            end)
            solve(q, best, hard)
        end
    end
  end

  defp do_play([spell | spells], player, boss) do
    case play_round(player, spell, boss) do
      {player, boss} ->
        do_play(spells, player, boss)
      winner ->
        winner
    end
  end

  defp play_round(player, spell, boss, hard \\ false) do
    case hard do
      true ->
        case player do
          %{hit_points: points} when points <= 1 ->
            :boss
          %{hit_points: points} ->
            player = %{player | hit_points: points - 1}
            do_play_round(player, spell, boss)
        end
      false ->
        do_play_round(player, spell, boss)
    end
  end

  defp do_play_round(player, spell, boss) do
    with {player, boss} <- hit_boss(player, spell, boss),
         {player, boss} <- hit_player(boss, player)
      do
         {player, boss}
    end
  end

  defp lost?(%{hit_points: points}), do: points <= 0

  defp init(player, boss) do
    player = player
    |> Map.put(:armor, 0)
    |> Map.put(:damage, 0)
    |> Map.put(:timers, [])

    boss = Map.put(boss, :armor, 0)

    {player, boss}
  end

  defp hit_boss(player, spell, boss) do
    {player, boss} = run_timers(player, boss)
    player = cast_spell(player, spell)
    case hit(player, boss) do
      {:ok, boss} ->
        {player, boss}
      nil ->
        :player
    end
  end

  defp hit_player(boss, player) do
    {player, boss} = run_timers(player, boss)
    case lost?(boss) do
      true ->
        :player
      false ->
        case hit(boss, player) do
          {:ok, player} ->
            {player, boss}
          nil ->
            :boss
        end
    end
  end

  defp hit(attacker, defender) do
    %{damage: damage} = attacker
    %{hit_points: points, armor: armor} = defender
    damage = if damage === 0 do
      0
    else
      max(damage - armor, 1)
    end
    points = points - damage
    defender = %{defender | hit_points: points}
    if points <= 0 do
      nil
    else
      {:ok, defender}
    end
  end

  defp possible_spells(player) do
    mana = Map.fetch!(player, :mana)
    all = ~w(magic_missile drain shield poison recharge)a
    timers = Map.fetch!(player, :timers)
    all -- Enum.reduce(timers, [], fn {type, turns}, acc ->
      if turns > 1, do: [type | acc], else: acc
    end)
    |> Enum.reject(fn spell -> cost(spell) > mana end)
  end

  defp cast_spell(player, spell) do
    player = deduct_mana(player, cost(spell))
    case spell do
      :magic_missile ->
        player
        |> add_property(:damage, 4)
      :drain ->
        player
        |> add_property(:hit_points, 2)
        |> add_property(:damage, 2)
      :shield ->
        player
        |> add_property(:armor, 7)
        |> set_timer(:shield, 6)
      :poison ->
        player
        |> set_timer(:poison, 6)
      :recharge ->
        player
        |> set_timer(:recharge, 5)
    end
  end

  defp deduct_mana(player, cost) do
    case player do
      %{mana: mana} when mana >= cost ->
        %{player | mana: mana - cost}
    end
  end

  defp add_property(player, property, offset) do
    Map.update!(player, property, &(&1 + offset))
  end

  defp set_timer(player, type, turns) do
    Map.update!(player, :timers, &([{type, turns} | &1]))
  end

  defp run_timers(player, boss) do
    timers = Map.fetch!(player, :timers)

    player = %{player | damage: 0, armor: 0}
    acc = {player, boss}
    {player, boss} =
      Enum.reduce(timers, acc,
        fn {type, turns}, {player, boss} ->
          case type do
            :shield ->
              if turns === 0 do
                {player, boss}
              else
                {add_property(player, :armor, 7), boss}
              end
            :poison ->
              {player, add_property(boss, :hit_points, -3)}
            :recharge ->
              {add_property(player, :mana, 101), boss}
          end
        end)

    timers = timers
    |> Enum.map(fn {type, turns} -> {type, turns - 1} end)
    |> Enum.reject(fn {_, turns} -> turns === 0 end)

    {%{player | timers: timers}, boss}
  end

  defp cost(:magic_missile), do: 53
  defp cost(:drain), do: 73
  defp cost(:shield), do: 113
  defp cost(:poison), do: 173
  defp cost(:recharge), do: 229
end
