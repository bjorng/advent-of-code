defmodule Day14 do
  def part1(input, seconds \\ 2503) do
    parse(input)
    |> Enum.map(fn {_name, speed, active, resting} ->
      cycles = div(seconds, active + resting)
      seconds_left = rem(seconds, active + resting)
      active_seconds = cycles * active + min(seconds_left, active)
      speed * active_seconds
    end)
    |> Enum.max
  end

  def part2(input, seconds \\ 2503) do
    parse(input)
    |> winning_scores
    |> Stream.drop(seconds)
    |> Enum.take(1)
    |> hd
  end

  defp winning_scores(reindeers) do
    reindeers = Enum.map(reindeers, fn {_name, speed, active, resting} ->
      {0, 0, {speed, active, resting}}
    end)
    Stream.unfold({reindeers, 0}, &next_second/1)
  end

  defp next_second({reindeers, seconds}) do
    reindeers = move(reindeers, seconds)

    winning_distance = Enum.map(reindeers, &elem(&1, 0))
    |> Enum.max

    reindeers = Enum.map(reindeers, fn {distance, points, data} ->
      if distance === winning_distance do
        {distance, points + 1, data}
      else
        {distance, points, data}
      end
    end)

    {_, winning_score, _} = Enum.max_by(reindeers, &(elem(&1, 1)))
    {winning_score, {reindeers, seconds + 1}}
  end

  defp move(reindeers, seconds) do
    Enum.map(reindeers, fn {distance, points, data} ->
      {speed, _, _} = data
      case is_active(seconds, data) do
        true ->
          {distance + speed, points, data}
        false ->
          {distance, points, data}
      end
    end)
  end

  defp is_active(seconds, {_, active, resting}) do
    cycle_length = active + resting
    rem(seconds, cycle_length) < active
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      [name, speed, active, resting] =
        Regex.run(~r/^(\w+)\D+(\d+)\D+(\d+)\D+(\d+)/, line, [capture: :all_but_first])
      {name, String.to_integer(speed),
       String.to_integer(active), String.to_integer(resting)}
    end)
  end
end
