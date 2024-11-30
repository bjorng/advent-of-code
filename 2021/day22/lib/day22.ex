defmodule Day22 do
  def part1(input) do
    parse(input)
    |> Enum.reject(fn {_, {xr, yr, zr}} ->
      Enum.any?([xr, yr, zr], fn r ->
        r.first < -50 || r.last > 50
      end)
    end)
    |> solve
  end

  def part2(input) do
    solve(parse(input))
  end

  def solve(operations) do
    cuboids = []
    operations
    |> Enum.reduce(cuboids, &execute/2)
    |> Enum.reduce(0, fn {xr, yr, zr}, count ->
      count + Range.size(xr) * Range.size(yr) * Range.size(zr)
    end)
  end

  defp execute({action, new_cuboid}, cuboids) do
    cuboids =
      Enum.flat_map(cuboids, fn old_cuboid ->
        if overlap?(old_cuboid, new_cuboid) do
          split_cuboid(old_cuboid, new_cuboid)
          |> Enum.reject(fn cuboid ->
            overlap?(cuboid, new_cuboid)
          end)
        else
          [old_cuboid]
        end
      end)
    case action do
      :on ->
        [new_cuboid | cuboids]
      :off ->
        cuboids
    end
  end

  defp split_cuboid(cuboid, reference) do
    split_cuboids([cuboid], reference, 0)
  end

  defp split_cuboids(cuboids, _reference, 3), do: cuboids
  defp split_cuboids(cuboids, reference, axis) do
    new_cuboids = Enum.flat_map(cuboids, &split_one(&1, reference, axis))
    split_cuboids(new_cuboids, reference, axis + 1)
  end

  defp split_one(cuboid, reference, axis) do
    cr = elem(cuboid, axis)
    rr = elem(reference, axis)
    [cr.first..rr.first-1//1,
     max(cr.first, rr.first)..min(cr.last, rr.last)//1,
     min(cr.last, rr.last)+1..cr.last//1]
     |> Enum.reject(&Range.size(&1) === 0)
    |> Enum.map(fn r ->
      put_elem(cuboid, axis, r)
    end)
  end

  defp overlap?({xr1, yr1, zr1}, {xr2, yr2, zr2}) do
    not (Range.disjoint?(xr1, xr2) or
      Range.disjoint?(yr1, yr2) or
      Range.disjoint?(zr1, zr2))
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      {on_off, rest} =
        case line do
          "on " <> rest ->
            {:on, rest}
          "off " <> rest ->
            {:off, rest}
        end
      {on_off,
       String.split(rest, ",")
       |> Enum.map(fn <<_, "=", rest::binary>> ->
         [from, to] =
           String.split(rest, "..")
           |> Enum.map(&String.to_integer/1)
         from..to
       end)
       |> List.to_tuple}
    end)
  end
end
