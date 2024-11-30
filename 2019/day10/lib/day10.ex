defmodule Day10 do
  def part1(input) do
    asteroids = make_map_set(input)
    x_range = 0..byte_size(hd(input))-1
    y_range = 0..length(input)-1
    limits = {x_range, y_range}

    asteroids
    |> Enum.map(fn pos ->
       {num_visible(asteroids, pos, limits), pos}
    end)
    |> Enum.max
  end

  def part2(input, center) do
    asteroids = make_map_set(input)
    asteroids = MapSet.delete(asteroids, center)
    x_range = 0..byte_size(hd(input))-1
    y_range = 0..length(input)-1
    limits = {x_range, y_range}
    blocked = all_blocked(asteroids, center, limits)
    vaporize_asteroids(asteroids, center, blocked)
  end

  defp vaporize_asteroids(asteroids, center, blocked) do
    asteroids
    |> Stream.reject(fn pos -> pos in blocked end)
    |> Enum.sort_by(fn pos ->
      angle = asteroid_angle(pos, center)
      distance = asteroid_distance(pos, center)
      {angle, - distance}
    end, &>=/2)
    |> Enum.drop(199)
    |> hd
    |> result
  end

  defp result({x, y}), do: x * 100 + y

  defp asteroid_angle({x, y}, {xc, yc}) do
    :math.atan2(x - xc, y - yc)
  end

  defp asteroid_distance({x, y}, {xc, yc}) do
    xdist = x - xc
    ydist = y - yc
    :math.sqrt(xdist * xdist + ydist * ydist)
  end

  defp num_visible(asteroids, pos, limits) do
    num_blocked = MapSet.size(all_blocked(asteroids, pos, limits))
    MapSet.size(asteroids) - num_blocked - 1
  end

  defp all_blocked(asteroids, pos, limits) do
    vectors(limits)
    |> Enum.flat_map(fn ray ->
      blocked(pos, ray, asteroids, limits)
    end)
    |> Enum.uniq
    |> MapSet.new
  end

  defp blocked(from, {x_inc, y_inc}, asteroids, limits) do
    Stream.iterate(from, fn {x, y} ->
      {x + x_inc, y + y_inc}
    end)
    |> Stream.drop(1)
    |> Enum.reduce_while(nil, fn pos, acc ->
      case pos in asteroids do
	true when acc === nil ->
	  {:cont, []}
	true ->
	  {:cont, [pos | acc]}
	false ->
	  case within_limits(pos, limits) do
	    true ->
	      {:cont, acc}
	    false when acc === nil ->
	      {:halt, []}
	    false ->
	      {:halt, acc}
	  end
      end
    end)
  end

  defp within_limits({x, y}, {x_range, y_range}) do
    x in x_range and y in y_range
  end

  defp vectors({x_range, y_range}) do
    _..max_x = x_range
    _..max_y = y_range
    Stream.flat_map(-max_x..max_x, fn x ->
      Stream.map(-max_y..max_y, fn y ->
	{x, y}
      end)
    end)
    |> Stream.reject(fn {x, y} -> x === 0 and y === 0 end)
    |> Stream.map(fn {x, y} ->
      abs_gcd = abs(gcd(x, y))
      {div(x, abs_gcd), div(y, abs_gcd)}
    end)
    |> Enum.uniq
  end

  defp gcd(a, 0), do: a
  defp gcd(a, b) do
    case rem(a, b) do
      0 -> b
      x -> gcd(b, x)
    end
  end

  defp make_map_set(input) do
    input
    |> Stream.with_index
    |> Enum.reduce(MapSet.new(), fn {line, y}, set ->
      String.to_charlist(line)
      |> Stream.with_index
      |> Enum.reduce(set, fn {char, x}, set ->
	case char do
	  ?\# -> MapSet.put(set, {x, y})
	  ?\. -> set
	end
      end)
    end)
  end
end
