defmodule Day12 do
  def part1(input, steps) do
    positions = read_positions(input)
    moons = Enum.map(positions, & {&1, {0, 0, 0}})
    Stream.iterate(moons, &update_moons/1)
    |> Enum.at(steps)
    |> Enum.map(&moon_energy/1)
    |> Enum.sum
  end

  def part2(input) do
    positions = read_positions(input)
    moons = Enum.map(positions, & {&1, {0, 0, 0}})
    Stream.iterate(moons, &update_moons/1)
    |> Stream.drop(1)
    |> Enum.reduce_while({1, {nil, nil, nil}}, fn state, {steps, cycles} ->
      cycles = update_cycles(state, cycles, steps, moons)
      case all_integers(cycles) do
	true ->
          {:halt, calculate_steps(Tuple.to_list(cycles))}
	false ->
	  {:cont, {steps + 1, cycles}}
      end
    end)
  end

  defp calculate_steps(cycles) do
    Enum.reduce(cycles, fn steps, acc ->
      gcd = Integer.gcd(steps, acc)
      div(steps * acc, gcd)
    end)
  end

  defp all_integers({xc, yc, zc}) do
    is_integer(xc) and is_integer(yc) and is_integer(zc)
  end

  defp update_cycles(state, {xc, xy, xz}, steps, moons) do
    {update_cycle(0, xc, state, steps, moons),
     update_cycle(1, xy, state, steps, moons),
     update_cycle(2, xz, state, steps, moons)}
  end

  defp update_cycle(i, nil, state, steps, moons) do
    is_same = Stream.zip(state, moons)
    |> Enum.all?(fn {{ps, vs}, {ips, ivs}} ->
      elem(ps, i) === elem(ips, i) and elem(vs, i) === elem(ivs, i)
    end)
    case is_same do
      true -> steps
      false -> nil
    end
  end
  defp update_cycle(_, cycle, _, _, _), do: cycle

  defp update_moons(moons) do
    move_moons(moons)
    |> Enum.map(fn {pos, vs} -> {vec_add(pos, vs), vs} end)
  end

  defp move_moons([moon | moons]) do
    {moon, moons} = move_moon(moon, moons)
    [moon | move_moons(moons)]
  end
  defp move_moons([]), do: []

  defp move_moon({ps1, vs1}, [{ps2, vs2} | moons]) do
    gravity = apply_gravity(ps1, ps2)
    vs1 = vec_sub(vs1, gravity)
    vs2 = vec_add(vs2, gravity)
    moon = {ps1, vs1}
    {moon, moons} = move_moon(moon, moons)
    {moon, [{ps2, vs2} | moons]}
  end
  defp move_moon(moon, []), do: {moon, []}

  defp apply_gravity(ps1, ps2) do
    {gx, gy, gz} = vec_sub(ps1, ps2)
    {sign(gx), sign(gy), sign(gz)}
  end

  defp moon_energy({ps, vs}) do
    energy(ps) * energy(vs)
  end

  defp energy({x, y, z}) do
    abs(x) + abs(y) + abs(z)
  end

  defp sign(0), do: 0
  defp sign(n) when n < 0, do: -1
  defp sign(n) when n > 0, do: 1

  defp vec_add({x1, y1, z1}, {x2, y2, z2}), do: {x1 + x2, y1 + y2, z1 + z2}
  defp vec_sub({x1, y1, z1}, {x2, y2, z2}), do: {x1 - x2, y1 - y2, z1 - z2}

  defp read_positions(input) do
    Enum.map(input, fn line ->
      result = Regex.run(~r/^<x=(-?\d+), y=(-?\d+), z=(-?\d+)>$/, line)
      Enum.map(tl(result), &String.to_integer/1)
      |> List.to_tuple
    end)
  end
end
