defmodule Day14 do
  def part1(input, iter, width, height) do
    robots = parse(input)
    dim = {width, height}
    hw = div(width, 2)
    hh = div(height, 2)

    1..iter
    |> Enum.reduce(robots, fn _, robots ->
      Enum.map(robots, &move(&1, dim))
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reject(fn {x, y} ->
      x === hw or y === hh
    end)
    |> Enum.group_by(fn {x, y} ->
      {div(x, hw + 1), div(y, hh + 1)}
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&length/1)
    |> Enum.product
  end

  def part2(input, iter, width, height) do
    robots = parse(input)
    dim = {width, height}

    # I found out this pattern by printing the
    # grid after each iteration and doing some
    # creative grepping to find the Christmas
    # tree.
    pattern = "*******************************"
    |> :binary.compile_pattern

    1..iter
    |> Enum.reduce_while(robots, fn i, robots ->
      robots = Enum.map(robots, &move(&1, dim))
      printed = print_grid(robots, width, height)
      case :binary.match(printed, pattern) do
        :nomatch ->
          {:cont, robots}
        _ ->
          {:halt, i}
      end
    end)
  end

  defp move({position, velocity}, {w,h}) do
    {x, y} = add(position, velocity)
    {{Integer.mod(x, w), Integer.mod(y, h)}, velocity}
  end

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp print_grid(robots, w, h) do
    grid = Enum.map(1..h, fn _ ->
      [:binary.copy(" ", w), ?\n]
    end)
    |> :erlang.iolist_to_binary
    w = w + 1

    Enum.reduce(robots, grid, fn {{col, row}, _}, grid ->
      pos = row * w + col
      <<prefix :: binary-size(pos), _, suffix :: binary>> = grid
      <<prefix :: binary, "*", suffix :: binary>>
    end)
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      ["p=" <> p, "v=" <> v] = String.split(line, " ")
      {parse_pair(p), parse_pair(v)}
    end)
  end

  defp parse_pair(s) do
    String.split(s, ",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end
