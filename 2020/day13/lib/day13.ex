defmodule Day13 do
  def part1(input) do
    {timestamp, bus_lines} = parse(input)

    Enum.reject(bus_lines, &(&1 === :x))
    |> Enum.map(fn id ->
      {id - rem(timestamp, id), id}
    end)
    |> Enum.min
    |> result
  end

  defp result({min, id}), do: min * id

  def part2(input) do
    {_, buses} = parse(input)
    buses = buses
    |> Enum.with_index
    |> Enum.reject(&(elem(&1, 0) === :x))

    solution = solve_v1(buses)
    ^solution = solve_v2(buses)
  end

  #
  # Solve using the Chinese remainder theorem.
  #

  defp solve_v1(buses) do
    buses
    |> Enum.map(fn {m, id} -> {m, -id} end)
    |> solve_crt
  end

  defp solve_crt(list) do
    {_, timestamp} = Enum.reduce(list, &solve_crt_pair/2)
    timestamp
  end

  defp solve_crt_pair({m0, r0}, {m1, r1}) do
    m = m0 * m1
    {1, m0prim, m1prim} = egcd(m0, m1)
    a = m1 * m1prim
    b = m0 * m0prim
    x = rem(m + rem(a * r0 + b * r1, m), m)
    {m, x}
  end

  @doc """
  Calculate extend gcd.

  https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm

  ## Examples

      iex> Day13.egcd(9, 69)
      {3, 8, -1}
      iex> Day13.egcd(31, 7)
      {1, -2, 9}
      iex> Day13.egcd(13, 17)
      {1, 4, -3}
      iex> Day13.egcd(1789, 1889)
      {1, 170, -161}
  """

  def egcd(a, b) do
    egcd(a, b, 1, 0, 0, 1)
  end

  defp egcd(r0, r1, s0, s1, t0, t1) do
    q = div(r0, r1)
    r = r0 - q * r1
    s = s0 - q * s1
    t = t0 - q * t1
    if (r === 0) do
      {r1, s1, t1}
    else
      egcd(r1, r, s1, s, t1, t)
    end
  end

  #
  # Solve using an algorithm suggested in the solution thread in the
  # subreddit.
  #

  defp solve_v2(bus_lines) do
    solve_v2(bus_lines, 0, 1)
  end

  defp solve_v2([], time, _step), do: time
  defp solve_v2([{id, minutes} | buses], time, step) do
    # Find the first possible departure time for this bus.
    time = Stream.iterate(time, &(&1 + step))
    |> Enum.find(fn time -> rem(time + minutes, id) === 0 end)

    # Solve for the remaining buses.
    solve_v2(buses, time, step * id)
  end

  def parse([timestamp, bus_lines]) do
    {String.to_integer(timestamp),
     bus_lines
     |> String.split(",")
     |> Enum.map(fn id ->
       case id do
         "x" -> :x
         _ -> String.to_integer(id)
       end
     end)
    }
  end
end
