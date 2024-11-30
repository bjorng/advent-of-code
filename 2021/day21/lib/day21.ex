defmodule Day21 do
  def part1(input) do
    parse(input)
    |> Day21_part1.solve
  end

  def part2(input) do
    parse(input)
    |> Day21_part2.solve
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      [pos] = Regex.run(~r/(\d+)$/, line, capture: :all_but_first)
      String.to_integer(pos)
    end)
    |> List.to_tuple
  end
end

defmodule Day21_part1 do
  def solve(input) do
    {pos1, pos2} = input
    players = [{pos1, 0}, {pos2, 0}]
    die = {0, 0}
    play(players, die, [])
  end

  defp play([{pos, score} | ps], die, acc) do
    {rolls, die} = Enum.map_reduce(1..3, die, fn _, die ->
      roll(die)
    end)
    steps = Enum.sum(rolls)
    pos = rem(pos + steps - 1, 10) + 1
    score = score + pos
    if score >= 1000 do
      [{_, loser_score}] = ps ++ acc
      {_, rolls} = die
      loser_score * rolls
    else
      play(ps, die, [{pos, score} | acc])
    end
  end
  defp play([], die, acc) do
    play(Enum.reverse(acc), die, [])
  end

  defp roll({face, rolls}) do
    face = rem(face, 100) + 1
    {face, {face, rolls + 1}}
  end
end

defmodule Day21_part2 do
  def solve(input) do
    {pos1, pos2} = input
    universa = [{%{1 => {pos1, 0}, 2 => {pos2, 0}}, 1}]
    play(universa, %{1 => 0, 2 => 0})
    |> Enum.map(fn {_, score} -> score end)
    |> Enum.max
  end

  defp play(universa, wins) do
    {universa, wins} =
      Enum.flat_map_reduce(universa, wins, fn {players, num_parents}, wins  ->
        do_one(players, num_parents, 1, wins)
      end)
    universa = consolidate(universa)

    {universa, wins} =
      Enum.flat_map_reduce(universa, wins, fn {players, num_parents}, wins ->
        do_one(players, num_parents, 2, wins)
      end)
    universa = consolidate(universa)

    case universa do
      [] ->
        wins
      _ ->
        play(Enum.uniq(universa), wins)
    end
  end

  defp do_one(state, num_parents, player_id, wins) do
    outcomes = play_one(state, player_id, num_parents)
    process_won(outcomes, wins, player_id)
  end

  defp process_won(outcomes, wins, player_id) do
    {ongoing, won} = Enum.split_with(outcomes, fn {state, _} ->
      Map.fetch!(state, player_id) !== :win
    end)

    num_won =
      Enum.map(won, fn {_, num_universa} -> num_universa end)
      |> Enum.sum

    wins = Map.update!(wins, player_id, &(&1 + num_won))

    {ongoing, wins}
  end

  defp consolidate(universa) do
    universa
    |> Enum.group_by(fn {state, _} -> state end)
    |> Enum.map(fn {state, list} ->
      sum =
        Enum.map(list, fn {_, freq} -> freq end)
        |> Enum.sum
      {state, sum}
    end)
  end


  defp play_one(state, player_id, num_parents) do
    roll3()
    |> Enum.map(fn {steps, num_universa} ->
      num_universa = num_universa * num_parents
      {pos, score} = Map.fetch!(state, player_id)
      pos = rem(pos + steps - 1, 10) + 1
      score = score + pos
      player_state = if score >= 21 do
        :win
      else
        {pos, score}
      end
      {Map.put(state, player_id, player_state), num_universa}
    end)
  end

  defp roll3() do
    Enum.flat_map(1..3, fn roll1 ->
      Enum.flat_map(1..3, fn roll2 ->
        Enum.map(1..3, fn roll3 ->
          [roll1, roll2, roll3]
        end)
      end)
    end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.frequencies
  end
end
