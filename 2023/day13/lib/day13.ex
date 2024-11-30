defmodule Day13 do
  import Bitwise

  def part1(input) do
    solve(input, &find_reflections_part1/2)
  end

  defp find_reflections_part1(patterns, factor) do
    patterns
    |> Enum.map(&bitify/1)
    |> Enum.flat_map(fn patterns ->
      Enum.flat_map(patterns, fn {mirror, pattern} ->
        case Enum.all?(pattern, fn {bits1, bits2} -> bits1 === bits2 end) do
          true ->
            [mirror * factor]
          false ->
            [0]
        end
      end)
    end)
    |> Enum.sum
  end

  def part2(input) do
    solve(input, &find_reflections_part2/2)
  end

  defp solve(input, reflection_finder) do
    input = parse(input)
    cols = Enum.map(input, fn pattern ->
      Enum.map(pattern, fn {row, col} -> {col, row} end)
    end)
    reflection_finder.(input, 1) + reflection_finder.(cols, 100)
  end

  defp find_reflections_part2(patterns, factor) do
    patterns
    |> Enum.map(&bitify/1)
    |> Enum.flat_map(fn patterns ->
      Enum.flat_map(patterns, fn {mirror, pattern} ->
        Enum.map(pattern, fn {a, b} ->
          bxor(a, b)
        end)
        |> Enum.frequencies_by(fn bits ->
          cond do
            bits === 0 -> :zero
            power_of_two?(bits) -> :one
            true -> :other
          end
        end)
        |> then(fn freq ->
          if Map.get(freq, :one, 0) === 1 and Map.get(freq, :other, 0) === 0 do
            [mirror * factor]
          else
            []
          end
        end)
      end)
    end)
    |> Enum.sum
  end

  defp power_of_two?(n) do
    (n &&& (n - 1)) === 0
  end

  defp bitify(pattern) do
    width = pattern
    |> Enum.max_by(&elem(&1, 1))
    |> then(&elem(&1, 1))
    width = width + 1

    pattern = pattern
    |> Enum.sort
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.sort
    |> Enum.map(fn {_, elements} ->
      Enum.reduce(elements, 0, fn {_, col}, acc ->
        acc ||| (1 <<< col)
      end)
      |> reverse_bits(width, 0)
    end)

    0..width-2
    |> Enum.map(fn mirror ->
      Enum.map(pattern, fn row ->
        mirror_width = min(mirror + 1, width - mirror - 1)
        mirror_mask = (1 <<< mirror_width) - 1
        left = (row >>> (width - mirror - 1)) &&& mirror_mask
        right = (row >>> (width - mirror - mirror_width - 1)) &&& mirror_mask
        right = reverse_bits(right, mirror_width, 0)
        {left, right}
      end)
      |> then(&{mirror + 1, &1})
    end)
  end

  defp reverse_bits(_bits, 0, acc), do: acc
  defp reverse_bits(bits, left, acc) do
    acc = (acc <<< 1) ||| (bits &&& 1)
    reverse_bits(bits >>> 1, left - 1, acc)
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.split("\n", trim: true)
      |> Enum.with_index
      |> Enum.flat_map(fn {line, row} ->
        line
        |> String.to_charlist
        |> Enum.with_index
        |> Enum.flat_map(fn {char, col} ->
          case char do
            ?\# -> [{row, col}]
            ?. -> []
          end
        end)
      end)
    end)
  end
end
