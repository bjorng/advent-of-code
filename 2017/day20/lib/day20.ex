defmodule Day20 do
  def part1(input) do
    ParticleParser.parse(input)
    |> Enum.with_index
    |> Enum.map(fn {{p, v, a}, index} ->
      {manhattan_distance(a), manhattan_distance(v),
       manhattan_distance(p), index}
    end)
    |> Enum.min
    |> elem(3)
  end

  def part2(input) do
    ps = ParticleParser.parse(input)
    iter(ps, 0)
  end

  # This is not a general solution, but it works with my input. (There
  # were some similar solutions in the subreddit. Seems that using
  # just 1000 iterations will find the correct answer for most or all
  # inputs.) A more general solution would terminate when the
  # remaining particles can't collide.  That could be checked one
  # dimension at the time.
  defp iter(ps, 50_000), do: Enum.count(ps)
  defp iter(ps, n) do
    res = Enum.map(ps, &move/1)
    |> Enum.sort()
    |> remove_collided()
    iter(res, n + 1)
  end

  defp remove_collided([{p, _, _}, {p, _, _} | ps]) do
    ps = Enum.drop_while(ps, fn {p1, _, _} -> p1 === p end)
    remove_collided(ps)
  end

  defp remove_collided([p | ps]) do
    [p | remove_collided(ps)]
  end

  defp remove_collided([]), do: []

  defp move({{x, y, z}, {vx, vy, vz}, {ax, ay, az} = a}) do
    vx = vx + ax
    vy = vy + ay
    vz = vz + az
    v = {vx, vy, vz}
    p = {x + vx, y + vy, z + vz}
    {p, v, a}
  end

  defp manhattan_distance({x, y, z}) do
    abs(x) + abs(y) + abs(z)
  end
end

defmodule ParticleParser do
  import NimbleParsec

  defp reduce_signed_integer(["-", integer]), do: -integer
  defp reduce_signed_integer([other]), do: other

  defp particle([p, v, a]), do: {p, v, a}

  blankspace = ignore(ascii_string([?\s], min: 1))
  comma = ignore(string(",")) |> optional(blankspace)

  signed_integer = optional(string("-"))
  |> integer(min: 1)
  |> reduce({:reduce_signed_integer, []})

  point = ignore(string("<"))
  |> optional(blankspace)
  |> concat(signed_integer)
  |> repeat(comma |> concat(signed_integer))
  |> ignore(string(">"))
  |> reduce({List, :to_tuple, []})

  defparsecp :particle,
    ignore(string("p="))
  |> concat(point)
  |> ignore(comma)
  |> ignore(string("v="))
  |> concat(point)
  |> ignore(comma)
  |> ignore(string("a="))
  |> concat(point)
  |> eos()
  |> reduce({:particle, []})

  def parse(input) do
    Enum.map(input, fn(line) ->
      {:ok, [res], _, _, _, _} = particle(line)
      res
    end)
  end
end


