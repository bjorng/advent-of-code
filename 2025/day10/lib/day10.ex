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
      {time, presses} = :timer.tc(fn -> one_machine(buttons, joltage) end)
      time = :erlang.float_to_binary(time / 1_000_000, decimals: 2)
      {presses, time, {buttons, joltage}}
    end)
    |> Enum.sum_by(fn {presses, time, input} ->
      IO.inspect(input)
      IO.puts("#{presses} presses in #{time} seconds")
      presses
    end)
  end

  defp one_machine(buttons, joltage) do
    buttons = Enum.sort_by(buttons, &popcount/1, :desc)
#    IO.inspect({buttons, joltage})
    levels = joltage
    |> Enum.reduce(0, fn level, levels ->
      (levels <<< 8) ||| level
    end)

    buttons = Enum.map(buttons, fn button ->
      increments(button, joltage)
    end)

    IO.inspect({buttons, joltage})
    seen = MapSet.new
    q = :gb_sets.singleton({0, length(buttons), levels, buttons})
    result = blurf({q, seen})
    IO.inspect result, label: :result
    result
#    configure_joltage(buttons, levels)
  end

  defp blurf({q, seen}) do
    {{steps, _, current, buttons}, q} = :gb_sets.take_smallest(q)
    if Process.get(:steps) !== steps and not :gb_sets.is_empty(q) do
      Process.put(:steps, steps)
      {largest, len, _, _} = :gb_sets.largest(q)
      IO.inspect {steps, current, :gb_sets.size(q), {largest, len}}, label: :steps
    end
    case current do
      0 ->
        steps
      _ ->
        [button | buttons] = buttons
        num_buttons = length(buttons)
        q = if buttons === [] do
          q
        else
          entry = {steps, num_buttons, current, buttons}
          :gb_sets.add(entry, q)
        end
        case do_max_presses(button, current, nil) do
          nil ->
            {q, seen}
          0 ->
            {q, seen}
          max when max >= 1 ->
            current = current - button
            entry = {steps + 1, num_buttons + 1, current, [button | buttons]}
            q = :gb_sets.add(entry, q)
            if buttons === [] do
              {q, seen}
            else
              next = Enum.reduce(buttons, 0, &(&1 ||| &2))
              IO.puts("#{Integer.to_string(button, 16)}")
              IO.puts("#{Integer.to_string(current, 16)}")
              IO.puts("#{Integer.to_string(next, 16)}")
              IO.puts ""
              if impossible?(button, current, next) do
                IO.inspect(current)
                {q, seen}
              else
                entry = {steps + 1, num_buttons, current, buttons}
                q = :gb_sets.add(entry, q)
                {q, seen}
              end
            end
        end
        |> blurf
    end
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
    case next &&& 0xff do
      0 ->
        case button &&& 0xff do
          1 ->
            diff = diffs &&& 0xff
            if diff === prev_diff or prev_diff === nil do
              do_impossible?(button >>> 8, diffs >>> 8, next >>> 8, prev_diff)
            else
              true
            end
          0 ->
            do_impossible?(button >>> 8, diffs >>> 8, next >>> 8, prev_diff)
        end
      1 ->
        do_impossible?(button >>> 8, diffs >>> 8, next >>> 8, prev_diff)
    end
  end

  defp presses(button, diffs, next) do
    min = if next === nil, do: 0, else: do_min_presses(diffs, next, 0)
    min .. do_max_presses(button, diffs, nil) // 1
  end

  defp do_min_presses(0, 0, largest), do: largest
  defp do_min_presses(diffs, next, largest) do
    case next &&& 0xff do
      0 ->
        diff = diffs &&& 0xff
        largest = max(diff, largest)
        do_min_presses(diffs >>> 8, next >>> 8, largest)
      1 ->
        do_min_presses(diffs >>> 8, next >>> 8, largest)
    end
  end

  defp do_max_presses(0, 0, smallest), do: smallest
  defp do_max_presses(button, diffs, smallest) do
    case button &&& 0xff do
      0 ->
        do_max_presses(button >>> 8, diffs >>> 8, smallest)
      1 ->
        diff = diffs &&& 0xff
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
