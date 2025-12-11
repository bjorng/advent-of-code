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
      |> Enum.reduce(0, fn level, levels ->
        (levels <<< 8) ||| level
      end)

      buttons = Enum.map(buttons, fn button ->
        increments(button, joltage)
      end)

      all = increments((1 <<< length(joltage)) - 1, joltage)

      buttons = buttons
      |> Enum.reverse
      |> Enum.map_reduce(0, fn elem, acc ->
        case acc do
          nil -> {{elem, nil}, nil}
          ^all -> {{elem, acc}, nil}
          _ -> {{elem, acc}, acc ||| elem}
        end
      end)
      |> elem(0)
      |> Enum.reverse

      configure_joltage(buttons, levels)
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

  defp configure_joltage(_, 0) do
    0
  end
  defp configure_joltage([], _current) do
    nil
  end
  defp configure_joltage([{button, next} | buttons], current) do
    case impossible?(button, current, next) do
      true ->
        nil
      false ->
        presses = presses(button, current, next)
        case Range.size(presses) do
          0 -> nil
          _ -> press(presses, button, buttons, current)
        end
    end
  end

  defp press(presses, button, buttons, current) do
    current = current - presses.first * button
    Enum.reduce(presses, {nil, current}, fn times, {best, current} ->
      case configure_joltage(buttons, current) do
        nil ->
          {best, current - button}
        n ->
          result = min(n + times, best)
          {result, current - button}
      end
    end)
    |> then(fn {best, _} ->
      best
    end)
  end

  defp impossible?(_button, _diffs, nil), do: false
  defp impossible?(button, diffs, next) do
    do_impossible?(button, diffs, next, nil)
  end

  defp do_impossible?(0, 0, _next, _diff), do: false
  defp do_impossible?(button, diffs, next, prev_diff) do
    case {button &&& 0xff, diffs &&& 0xff, next &&& 0xff} do
      {1, diff, 0} ->
        if diff === prev_diff or prev_diff === nil do
          do_impossible?(button >>> 8, diffs >>> 8, next >>> 8, prev_diff)
        else
          true
        end
      {_, _, _} ->
        do_impossible?(button >>> 8, diffs >>> 8, next >>> 8, prev_diff)
    end
  end

  defp presses(button, diffs, next) do
    min = if next === nil, do: 0, else: do_min_presses(diffs, next, 0)
    min .. do_max_presses(button, diffs, nil) // 1
  end

  defp do_min_presses(0, 0, largest), do: largest
  defp do_min_presses(diffs, next, largest) do
    case {diffs &&& 0xff, next &&& 0xff} do
      {diff, 0} ->
        largest = max(diff, largest)
        do_min_presses(diffs >>> 8, next >>> 8, largest)
      {_, _} ->
        do_min_presses(diffs >>> 8, next >>> 8, largest)
    end
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
