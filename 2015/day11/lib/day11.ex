defmodule Day11 do
  def part1(input) do
    input
    |> to_charlist
    |> Stream.iterate(&increment_password/1)
    |> Stream.filter(&is_valid/1)
    |> Enum.take(1)
    |> hd
    |> List.to_string
  end

  def part2(input) do
    input
    |> part1
    |> to_charlist
    |> increment_password
    |> List.to_string
    |> part1
  end

  def is_valid(chars) do
    (not Enum.any?(chars, &(&1 in 'iol'))) and
    three_letters_increasing?(chars) and
    has_two_pairs?(chars)
  end

  defp three_letters_increasing?(chars) do
    chars
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.any?(fn [a, b, c] ->
      a+1 == b and b+1 == c
    end)
  end

  defp has_two_pairs?(chars), do: has_two_pairs?(chars, 0)

  defp has_two_pairs?([c, c | chars], num_pairs) do
    has_two_pairs?(chars, num_pairs + 1)
  end
  defp has_two_pairs?([_ | chars], num_pairs) do
    has_two_pairs?(chars, num_pairs)
  end
  defp has_two_pairs?([], num_pairs), do: num_pairs >= 2

  defp increment_password([c]) do
    case c do
      ?z -> {:carry, [?a]}
      _ -> [c + 1]
    end
  end
  defp increment_password([c | chars]) do
    case increment_password(chars) do
      {:carry, chars} ->
        case c do
          ?z -> {:carry, [?a | chars]}
          _ -> [c + 1 | chars]
        end
      chars ->
        [c | chars]
    end
  end
end
