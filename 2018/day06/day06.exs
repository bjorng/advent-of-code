#
# I struggled with this one a looong time. I got the answers in the
# end, but I had to add hard-coded iteration limits. So this solution
# may not work with other input data.
#
# To run tests:
#
#    elixir day06.exs
#
# To run part 1 and 2:
#
#    > iex day06.exs
#    [iex]> Day06.part1
#    [iex]> Day06.part2
#

defmodule Day06 do

  def part1 do
    largest_area(input())
  end

  def part2 do
    less_than(input(), 10000)
  end

  def input do
    "input.txt"
    |> File.stream!([], :line)
    |> Enum.map(fn line -> String.trim(line) end)
  end

  def less_than(coordinates, limit) do
    coordinates = coordinates
    |> Enum.map(&parse_line/1)
    # NOTE: Hard-code limits for iterations. This may
    # not work with other people's input data.
    less =
    for x <- -500..1000,
      y <- -500..1000,
      less_than({x, y}, coordinates, limit),
	do: {x, y}
	length(less)
  end

  defp less_than(coord, coordinates, limit) when limit > 0 do
    case coordinates do
      [h | t] ->
	less_than(coord, t, limit - distance(h, coord));
      [] ->
	true
    end
  end

  defp less_than(_coord, _coordinates, _limit), do: false

  defp distance {x0, y0}, {x, y} do
    abs(x0 - x) + abs(y0 - y)
  end

  def largest_area(coordinates) do
    coordinates = coordinates
    |> Enum.map(&parse_line/1)
    seeds =
      coordinates
      |> Enum.map(fn seed ->
      seed_map = MapSet.new([seed]); {seed_map, seed_map, seed}
    end)
    owners =
    for coord <- coordinates, into: %{}, do: {coord, {coord, 0, :limited}}
    owners = grow seeds, owners, 1
    result owners
  end

  # NOTE: Hard-code upper limit for the number of iterations. This may
  # not work with other people's input data.
  defp grow(seeds, owners, dist) when dist < 120 do
    seeds = grow_seeds seeds
    owners = Enum.reduce(seeds, owners,
      fn {boundary, _, owner}, acc ->
	Enum.reduce(boundary, acc,
	  fn point, acc ->
	    update_owner owner, point, dist, acc
	  end)
      end)

    # IO.inspect({dist,result(owners)})

    grow seeds, owners, dist + 1
  end

  defp grow(_seeds, owners, _dist) do
    owners
  end

  defp update_owner owner, point, dist, owners do
    case owners do
      %{^point => {other_owner, other_dist, :unlimited}} when other_owner != owner and other_dist < dist ->
	%{owners | point => {other_owner, other_dist, :limited}}
      %{^point => {other_owner, other_dist, :unlimited}} when other_owner != owner and other_dist == dist ->
	%{owners | point => {other_owner, other_dist, :tied}}
      %{^point => {_other_owner, _other_dist, :limited}} ->
	owners
      %{^point => {_other_owner, _other_dist, :tied}} ->
	owners
      %{} ->
	Map.put owners, point, {owner, dist, :unlimited}
    end
  end

  defp grow_seeds seeds do
    Enum.map(seeds, fn {new, all, origin} ->
      new = new_points new, all
      all = MapSet.union(new, all)
      {new, all, origin}
    end)
  end

  defp result(owners) do
    owners
    |> Enum.group_by(fn {_, {owner, _, _}} -> owner end)
    |> Enum.reject(fn {_, points} ->
      Enum.any?(points, fn {_, {_, _, limit}} -> limit == :unlimited end)
    end)
    |> Enum.map(fn {_, points} ->
      Enum.reject(points, fn {_, {_, _, status}} -> status == :tied end)
    end)
    |> Enum.map(fn points -> length(points) end)
    |> Enum.max(fn -> 0 end)
  end

  defp parse_line(line) do
    {x, <<", ",line::binary>>} = Integer.parse line
    {y, <<>>} = Integer.parse line
    {x, y}
  end

  defp new_points points, all do
    Enum.reduce(points, MapSet.new(), fn {x, y}, acc ->
      new = [{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}]
      Enum.reduce(new, acc,
	fn point, acc ->
	  case point in all do
	    false -> MapSet.put acc, point
	    true -> acc
	  end
	end)
    end)
  end

end

ExUnit.start()
defmodule Day06Test do
  use ExUnit.Case

  import Day06

  test "part one" do
    #assert largest_area(data()) == 17
  end

  test "part two" do
    assert less_than(data(), 32) == 16
  end

  defp data do
  """
  1, 1
  1, 6
  8, 3
  3, 4
  5, 5
  8, 9
  """
    |> String.trim
    |> String.split("\n")
  end

end
