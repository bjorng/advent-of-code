defmodule Day05 do
  def part1(input) do
    input
    |> Enum.map(fn code ->
      {row, col} = decode_seat(code)
      row * 8 + col
    end)
    |> Enum.max
  end

  def part2(input) do
    input
    |> Enum.map(fn code ->
      {row, col} = decode_seat(code)
      row * 8 + col
    end)
    |> Enum.sort
    |> find_my_seat
  end

  defp find_my_seat([seat1, seat2 | _])
  when seat2 - seat1 === 2 do
               seat1 + 1
  end
  defp find_my_seat([_ | seats]) do
    find_my_seat(seats)
  end

  @doc """
  Decode the code on the boarding pass to find the seat.

  ## Examples

      iex> Day05.decode_seat("FBFBBFFRLR")
      {44, 5}
      iex> Day05.decode_seat("BFFFBBFRRR")
      {70, 7}
      iex> Day05.decode_seat("FFFBBBFRRR")
      {14, 7}
      iex> Day05.decode_seat("BBFFBBFRLL")
      {102, 4}

  """
  def decode_seat(code) do
    {row.._, col.._} = code
    |> String.to_charlist
    |> Enum.reduce({0..127, 0..7}, &decode_char/2)
    {row, col}
  end

  defp decode_char(char, {rows, cols}) do
    case char do
      ?F ->
        first..last = rows
        {first .. first + div(last - first, 2), cols}
      ?B ->
        first..last = rows
        {first + div(last - first, 2)+1 .. last, cols}
      ?L ->
        first..last = cols
        {rows, first .. first + div(last - first, 2)}
      ?R ->
        first..last = cols
        {rows, first + div(last - first, 2)+1 .. last}
    end
  end
end
