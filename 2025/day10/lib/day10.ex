defmodule Day10 do
  import Bitwise

  def part1(input) do
    parse(input)
    |> Enum.map(fn {lights, buttons, _} ->
      {n, _} = configure(buttons, 0, lights, %{})
      n
    end)
    |> Enum.sum
  end

  defp configure(_, lights, lights, memo) do
    {0, memo}
  end
  defp configure([], _current, _lights, memo) do
    {nil, memo}
  end
  defp configure([button | buttons], current, lights, memo) do
    {n1, memo} = configure(buttons, current, lights, memo)
    {n2, memo} = configure(buttons, bxor(current, button), lights, memo)
    n = if n2 === nil, do: nil, else: n2 + 1
    {min(n1, n), memo}
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn {_, buttons, joltage} ->
      IO.inspect({buttons, joltage})
      max_presses = Enum.max(joltage)
      levels = joltage
#      |> Enum.reverse
      |> Enum.reduce(0, fn level, levels ->
        (levels <<< 8) ||| level
      end)

      buttons = Enum.map(buttons, fn button ->
#        IO.inspect button, label: :button
        increments(button, joltage)
      end)

      {best, _} = configure_joltage(buttons, 0..max_presses, 0, levels, %{})
      best
    end)
    |> IO.inspect
    |> Enum.sum
  end

  defp configure_joltage(_, _max_presses, levels, levels, memo) do
    {0, memo}
  end
  defp configure_joltage([], _max_presses, _current, _levels, memo) do
    {nil, memo}
  end
  defp configure_joltage([button | buttons], max_presses, current, levels, memo) do
    key = (current <<< 8) ||| (length(buttons) + 1)
    case memo do
      %{^key => best} ->
        {best, memo}
      %{} ->
#      	IO.inspect({button, current, levels})
        presses = 0..max_presses(button, current, levels, 255)//1
#	IO.inspect({presses, max_presses})
        {best, memo} = press(presses, button, buttons, current, levels, memo)
        {best, Map.put(memo, key, best)}
    end
  end

  defp max_presses(_button, 0, _levels, smallest), do: smallest
  defp max_presses(button, current, levels, smallest) do
    case {button &&& 0xff, current &&& 0xff, levels &&& 0xff} do
      {inc, value, limit} when inc + value > limit ->
        0
      {0, _value, _limit} ->
        max_presses(button >>> 8, current >>> 8, levels >>> 8, smallest)
      {1, value, limit} ->
        smallest = min(limit - value + 1, smallest)
        max_presses(button >>> 8, current >>> 8, levels >>> 8, smallest)
    end
  end

  defp press(presses, button, buttons, current, levels, memo) do
#    IO.inspect({presses, button, current, levels})
    Enum.reduce(presses, {nil, current, memo}, fn times, {best, current, memo} ->
      {n, memo} = configure_joltage(buttons, presses, current, levels, memo)
      n = if n === nil, do: nil, else: n + times
      result = min(n, best)
      {result, current + button, memo}
    end)
    |> then(fn {best, _, memo} ->
      {best, memo}
    end)
  end

  defp increments(button, joltage) do
    Enum.reduce(joltage, {button, 0}, fn _, {button, acc} ->
      acc = acc <<< 8
      case button &&& 1 do
        0 -> {button >>> 1, acc}
        1 -> {button >>> 1, acc ||| 1}
      end
    end)
    |> then(fn {_, button} -> button end)
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [lights | rest] = String.split(line, " ")

      lights = String.slice(lights, 1, String.length(lights) - 2)
      |> String.reverse
      |> String.to_charlist
      |> Enum.reduce(0, fn light, lights ->
        lights = lights <<< 1
        case light do
          ?. -> lights
          ?\# -> lights ||| 1
        end
      end)

      {buttons, [joltage]} = Enum.split(rest, length(rest) - 1)

      buttons = Enum.map(buttons, fn button ->
        button
        |> String.slice(1, String.length(button) - 2)
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> Enum.reduce(0, &((1 <<< &1) ||| &2))
      end)

      joltage = joltage
      |>String.slice(1, String.length(joltage) - 2)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

      {lights, buttons, joltage}
    end)
  end
end
