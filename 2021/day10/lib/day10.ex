defmodule Day10 do
  def part1(input) do
    parse(input)
    |> Enum.reduce(0, fn line, sum ->
      case find_errors(line) do
        {:incomplete, _} -> sum
        {:corrupted, char} -> sum + corrupted_score(char)
      end
    end)
  end

  def part2(input) do
    parse(input)
    |> Enum.reduce([], fn line, acc ->
      case find_errors(line) do
        {:corrupted, _} -> acc
        {:incomplete, chars} -> [completion_score(chars) | acc]
      end
    end)
    |> Enum.sort
    |> median
  end

  defp find_errors(line) do
    find_errors(line, [])
  end

  defp find_errors([char | chars], stack) do
    case {classify(char), stack} do
      {{:open, closing}, _} ->
        find_errors(chars, [closing | stack])
      {:close, [^char | stack]} ->
        find_errors(chars, stack)
      {:close, _stack} ->
        {:corrupted, char}
    end
  end
  defp find_errors([], [_ | _] = stack) do
    {:incomplete, stack}
  end
  defp find_errors([], []) do
    :ok
  end

  defp corrupted_score(char) do
    case char do
      ?\) -> 3
      ?\] -> 57
      ?\} -> 1197
      ?\> -> 25137
    end
  end

  defp completion_score(chars) do
    Enum.reduce(chars, 0, fn char, acc ->
      acc * 5 +
      case char do
        ?\) -> 1
        ?\] -> 2
        ?\} -> 3
        ?\> -> 4
      end
    end)
  end

  defp median(list) do
    Enum.at(list, div(length(list), 2))
  end

  defp classify(char) do
    case char do
      ?\( -> {:open, ?\)}
      ?\[ -> {:open, ?\]}
      ?\{ -> {:open, ?\}}
      ?\< -> {:open, ?>}
      ?\) -> :close
      ?\] -> :close
      ?\} -> :close
      ?\> -> :close
    end
  end

  defp parse(input) do
    Enum.map(input, &String.to_charlist/1)
  end
end
