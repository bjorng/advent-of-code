#
# To run tests:
#
#    elixir day03.exs
#
# To run part 1 and 2:
#
#    > iex day03.exs
#    [iex]> Day03.part1
#    [iex]> Day03.part2
#

defmodule Day03 do
  def part1 do
    overlap(string_stream("input.txt"))
  end

  def part2 do
    no_overlap(string_stream("input.txt"))
  end

  def overlap(list) do
    list
    |> Enum.map(&parse_line/1)
    |> Enum.flat_map(&expand/1)
    |> Enum.group_by(fn {pos, _} -> pos end)
    |> Enum.filter(fn {_key, value} -> length(value) > 1 end)
    |> Enum.count
  end

  def no_overlap(lines) do
    Enum.map(lines, &parse_line/1)
    |> Enum.flat_map(fn {id, {x0,y0}, {w,h}} ->
      area = w * h
      for x <- x0..x0+w-1, y <- y0..y0+h-1, do: {{x,y},{id,area}}
    end)
    |> Enum.group_by(fn {pos, _} -> pos end, fn {_pos, id_area} -> id_area end)
    |> Enum.filter(fn {_key, value} -> length(value) == 1 end)
    |> Enum.group_by(fn {_pos, [id_area]} -> id_area end)
    |> Enum.filter(fn {{_id,area}, squares} -> area == length(squares) end)
    |> Enum.map(fn {{id,_area}, _} -> id end)
    |> hd
  end

  defp parse_line(line) do
    <<"#",line::binary>> = line
    {id, <<" @ ",line::binary>>} = Integer.parse line
    {x, <<",",line::binary>>} = Integer.parse line
    {y, <<": ",line::binary>>} = Integer.parse line
    {w, <<"x",line::binary>>} = Integer.parse line
    {h, ""} = Integer.parse line
    {id, {x,y}, {w,h}}
  end

  defp expand({id, {x0,y0}, {w,h}}) do
    for x <- x0..x0+w-1, y <- y0..y0+h-1, do: {{x,y},id}
  end

  defp string_stream(f) do
    File.stream!(f)
    |> Enum.map(fn line -> String.trim(line) end)
  end
end

ExUnit.start()

defmodule Day03Test do
  use ExUnit.Case

  import Day03

  test "part one" do
    assert overlap(["#1 @ 1,3: 4x4",
		    "#2 @ 3,1: 4x4",
		    "#3 @ 5,5: 2x2"]) == 4

  end

  test "part two" do
    input = ["#1 @ 1,3: 4x4",
	     "#2 @ 3,1: 4x4",
	     "#3 @ 5,5: 2x2"]
    assert no_overlap(input) == 3
  end

end
