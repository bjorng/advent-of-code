defmodule Day15 do
  def part1(input) do
    start = parse(input)
    init_turns(start, 1, 2021, %{})
  end

  def part2(input) do
    start = parse(input)
    init_turns(start, 1, 30_000_001, %{})
  end

  defp init_turns([last], turn, turn_limit, last_spoken) do
    last_spoken = Map.put(last_spoken, last, [turn])
    speak(last, turn + 1, turn_limit, last_spoken)
  end
  defp init_turns([h | t], turn, turn_limit, last_spoken) do
    last_spoken = Map.put(last_spoken, h, [turn])
    init_turns(t, turn + 1, turn_limit, last_spoken)
  end

  defp speak(number, turn, turn, _last_spoken), do: number
  defp speak(number, turn, turn_limit, last_spoken) do
    case last_spoken do
      %{^number => [_]} ->
        last_spoken = update_last_spoken(last_spoken, 0, turn)
        speak(0, turn + 1, turn_limit, last_spoken)
      %{^number => [prev1, prev2]} ->
        age = prev1 - prev2
        last_spoken = update_last_spoken(last_spoken, age, turn)
        speak(age, turn + 1, turn_limit, last_spoken)
      %{} ->
        last_spoken = update_last_spoken(last_spoken, 0, turn)
        speak(0, turn + 1, turn_limit, last_spoken)
    end
  end

  defp update_last_spoken(last_spoken, number, turn) do
    case last_spoken do
      %{^number => [previous | _]} ->
        %{last_spoken | number => [turn, previous]}
      %{} ->
        Map.put(last_spoken, number, [turn])
    end
  end

  defp parse(input) do
    String.split(input, ",")
    |> Enum.map(&String.to_integer/1)
  end
end
