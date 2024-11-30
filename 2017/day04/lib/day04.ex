defmodule Day04 do
  def part1(stream) do
    stream
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> String.split(line, " ") end)
    |> Stream.filter(&is_valid/1)
    |> Enum.count
  end

  def part2(stream) do
    stream
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> String.split(line, " ") end)
    |> Stream.filter(&is_valid/1)
    |> Stream.reject(&any_anagram/1)
    |> Enum.count
  end

  defp is_valid(words) do
    words === Enum.uniq(words)
  end

  defp any_anagram(words) do
    words
    |> Stream.map(fn word ->
      String.split(word, "", trim: true) |> Enum.sort
    end)
    |> Stream.uniq
    |> Enum.count
    |> (& &1 != length(words)).()
  end

end
