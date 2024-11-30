#
# To run tests:
#
#    elixir day04.exs
#
# To run part 1 and 2:
#
#    > iex day04.exs
#    [iex]> Day04.part1
#    [iex]> Day04.part2
#

defmodule Day04 do
  def part1 do
    longest_sleep(sorted_input())
  end

  def part2 do
    sleep_minute(sorted_input())
  end

  def sorted_input() do
    "input.txt"
    |> File.stream!([], :line)
    |> Enum.map(fn line -> String.trim(line) end)
    |> Enum.sort
  end

  def longest_sleep(events) do
    events
    |> Enum.map(&parse/1)
    |> Enum.scan(&scan/2)
    |> Enum.reject(fn {minutes, _guard} -> is_integer(minutes) end)
    |> calculate_time
    |> Enum.group_by(fn {_, _, guard} -> guard end)
    |> Enum.max_by(fn {_, val} -> sleep_sum(val) end)
    |> guard_product
  end

  def sleep_minute(events) do
    events
    |> Enum.map(&parse/1)
    |> Enum.scan(&scan/2)
    |> Enum.reject(fn {minutes, _guard} -> is_integer(minutes) end)
    |> calculate_time
    |> Enum.flat_map(&expand_minutes/1)
    |> Enum.sort
    |> Enum.chunk_by(&(&1))
    |> Enum.max_by(&(length(&1)))
    |> (fn [{min, guard} | _] -> min * guard end).()
  end

  defp parse(line) do
    re = ~r/^\[[^:]+:(\d\d)\]\s*(.*)/
    [minutes, str] = Regex.run(re, line, [capture: :all_but_first])
    minutes = String.to_integer minutes
    {minutes,
     case Regex.run ~r/^Guard #(\d+)/, str, [capture: :all_but_first] do
       [number] ->
	 String.to_integer(number)
       nil ->
	 case str do
	   "falls asleep" ->
	     :falls_asleep
	   "wakes up" ->
	     :wakes_up
	 end
     end}
  end

  defp scan(val, acc) do
    case val do
      {minutes, new_guard} when is_integer(new_guard) ->
	{minutes, new_guard}
      {_minutes, _sleep} = pair ->
	{_, guard} = acc;
	{pair, guard}
    end
  end

  defp calculate_time([{{start_time, :falls_asleep}, guard},
		       {{end_time, :wakes_up}, guard} | rest]) do
    time = end_time - start_time
    [{start_time, time, guard} | calculate_time(rest)]
  end
  defp calculate_time([]), do: []

  defp sleep_sum(list) do
    Enum.reduce(list, 0, fn {_, sleep, _}, acc -> sleep + acc end)
  end

  defp guard_product {guard, periods} do
    minutes = for {start, time, _} <- periods, min <- start..start+time-1, do: min
    minutes
    |> Enum.sort
    |> Enum.chunk_by(&(&1))
    |> Enum.max_by(&(length(&1)))
    |> (fn [min | _] -> min * guard end).()
  end

  defp expand_minutes {start, time, guard} do
    for min <- start..start+time-1, do: {min, guard}
  end

end

ExUnit.start()

defmodule Day04Test do
  use ExUnit.Case

  import Day04

  test "part one" do
    assert longest_sleep(data()) == 240
  end

  test "part two" do
    assert sleep_minute(data()) == 4455
  end

  defp data do
  """
  [1518-11-01 00:00] Guard #10 begins shift
  [1518-11-01 00:05] falls asleep
  [1518-11-01 00:25] wakes up
  [1518-11-01 00:30] falls asleep
  [1518-11-01 00:55] wakes up
  [1518-11-01 23:58] Guard #99 begins shift
  [1518-11-02 00:40] falls asleep
  [1518-11-02 00:50] wakes up
  [1518-11-03 00:05] Guard #10 begins shift
  [1518-11-03 00:24] falls asleep
  [1518-11-03 00:29] wakes up
  [1518-11-04 00:02] Guard #99 begins shift
  [1518-11-04 00:36] falls asleep
  [1518-11-04 00:46] wakes up
  [1518-11-05 00:03] Guard #99 begins shift
  [1518-11-05 00:45] falls asleep
  [1518-11-05 00:55] wakes up
  """
  |> String.trim
  |> String.split("\n")
  end
end
