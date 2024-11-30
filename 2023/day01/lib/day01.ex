defmodule Day01 do
  def part1(input) do
    input
    |> Enum.map(fn line ->
      digits = String.to_charlist(line)
      |> Enum.filter(fn c ->
        c in ?0..?9
      end)
      first = hd(digits)
      last = List.last(digits)
      List.to_integer([first,last])
    end)
    |> Enum.sum
  end

  def part2(input) do
    input
    |> Enum.map(fn line ->
      digits = extract_digits(line)
      first = hd(digits)
      last = List.last(digits)
      first * 10 + last
    end)
    |> Enum.sum
  end

  defp extract_digits(line) do
      case line do
        <<"one", rest::binary>> ->
          [1 | extract_digits("e" <> rest)]
        <<"two", rest::binary>> ->
          [2 | extract_digits("o" <> rest)]
        <<"three", rest::binary>> ->
          [3 | extract_digits("e" <> rest)]
        <<"four", rest::binary>> ->
          [4 | extract_digits("r" <> rest)]
        <<"five", rest::binary>> ->
          [5 | extract_digits("e" <> rest)]
        <<"six", rest::binary>> ->
          [6 | extract_digits("x" <> rest)]
        <<"seven", rest::binary>> ->
          [7 | extract_digits("n" <> rest)]
        <<"eight", rest::binary>> ->
          [8 | extract_digits("t" <> rest)]
        <<"nine", rest::binary>> ->
          [9 | extract_digits("e" <> rest)]
        <<digit, rest::binary>> when digit in ?0..?9 ->
          [digit - ?0 | extract_digits(rest)]
        <<_, rest::binary>> ->
          extract_digits(rest)
        <<>> ->
          []
      end
  end
end
