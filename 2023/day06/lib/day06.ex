defmodule Day06 do
  def part1(input) do
    parse_part1(input)
    |> Enum.map(&number_of_ways_to_win/1)
    |> Enum.product
  end

  def part2(input) do
    parse_part2(input)
    |> number_of_ways_to_win
  end

  defp number_of_ways_to_win({time, distance}) do
    times = 1 .. time - 1
    Enum.reduce(times, 0, fn button_time, ways_to_win ->
      if button_time * (time - button_time) > distance do
        ways_to_win + 1
      else
        ways_to_win
      end
    end)
  end

  defp parse_part1(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> tl
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip
  end

  defp parse_part2(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.split(":", trim: true)
      |> tl
      |> hd
      |> String.replace(" ", "", [:global])
      |> String.to_integer
    end)
    |> List.to_tuple
  end
end
