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
      buttons = Enum.sort_by(buttons, &popcount/1, :desc)
      IO.inspect({buttons, joltage})
      levels = joltage
#      |> Enum.reverse
      |> Enum.reduce(0, fn level, levels ->
        (levels <<< 8) ||| level
      end)

      buttons = Enum.map(buttons, fn button ->
#        IO.inspect button, label: :button
        increments(button, joltage)
      end)

      {best, _} = configure_joltage(buttons, 0, levels, %{})
      best
      |> IO.inspect(label: :presses)
    end)
    |> IO.inspect
    |> Enum.sum
  end

  defp popcount(0), do: 0
  defp popcount(n) do
    case n &&& 1 do
      1 -> 1 + popcount(n >>> 1)
      0 -> popcount(n >>> 1)
    end
  end

  defp configure_joltage(_, levels, levels, memo) do
    {0, memo}
  end
  defp configure_joltage([], _current, _levels, memo) do
    {nil, memo}
  end
  defp configure_joltage([button | buttons], current, levels, memo) do
    next = next(buttons)
    case blurf(button, current, levels, next) do
      true ->
        {nil, memo}
      false ->
        min = min_presses(current, levels, next)
        max = max_presses(button, current, levels)
        presses = min..max//1

        press(presses, button, buttons, current, levels, memo)
    end
  end

  defp press(presses, button, buttons, current, levels, memo) do
    #    IO.inspect({presses, button, current, levels})
    current = if Range.size(presses) === 0 do
      current
    else
      current + presses.first * button
    end
    Enum.reduce(presses, {nil, current, memo}, fn times, {best, current, memo} ->
      {n, memo} = configure_joltage(buttons, current, levels, memo)
      if n === nil do
        {best, current + button, memo}
      else
        result = min(n + times, best)
        {result, current + button, memo}
      end
    end)
    |> then(fn {best, _, memo} ->
      {best, memo}
    end)
  end

  defp min_presses(current, levels, next) do
    do_min_presses(levels - current, next, 0)
  end

  defp do_min_presses(0, 0, largest), do: largest
  defp do_min_presses(diffs, next, largest) do
    case {diffs &&& 0xff, next &&& 0xff} do
      {diff, 0} ->
        largest = max(diff, largest)
        do_min_presses(diffs >>> 8, next >>> 8, largest);
      {_, _} ->
        do_min_presses(diffs >>> 8, next >>> 8, largest);
    end
  end

  defp max_presses(button, current, levels) do
    do_max_presses(button, levels - current, nil)
  end

  defp do_max_presses(0, 0, smallest), do: smallest
  defp do_max_presses(button, diffs, smallest) do
    case {button &&& 0xff, diffs &&& 0xff} do
      {0, _diff} ->
        do_max_presses(button >>> 8, diffs >>> 8, smallest)
      {1, diff} ->
        smallest = min(diff, smallest)
        do_max_presses(button >>> 8, diffs >>> 8, smallest)
    end
  end

  defp next(buttons) do
    Enum.reduce(buttons, 0, &(&1 ||| &2))
  end

  defp blurf(button, current, levels, next) do
    ds = do_blurf(button, current, levels, next, [])
    |> Enum.uniq
    case ds do
      [] -> false
      [_] -> false
      [_|_] -> true
    end
  end

  defp do_blurf(_button, _current, 0, _next, largest), do: largest
  defp do_blurf(button, current, levels, next, largest) do
    case {button &&& 0xff, current &&& 0xff, levels &&& 0xff, next &&& 0xff} do
      {1, value, limit, 0} ->
        largest = [limit - value | largest]
        do_blurf(button >>> 8, current >>> 8, levels >>> 8, next >>> 8, largest);
      {_, _, _, _} ->
        do_blurf(button >>> 8, current >>> 8, levels >>> 8, next >>> 8, largest);
    end
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
