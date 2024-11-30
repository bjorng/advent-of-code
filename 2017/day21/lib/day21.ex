defmodule Day21 do
  import Bitwise

  def part1(input, iterations \\ 5) do
    solve(input, iterations)
  end

  def part2(input, iterations \\ 18) do
    solve(input, iterations)
  end

  defp solve(input, iterations) do
    rules = parse(input)
    |> Map.new

    starter_image()
    |> Stream.iterate(fn image -> enhance(image, rules) end)
    |> Stream.drop(iterations)
    |> Enum.take(1)
    |> hd
    |> count_ones
  end

  defp enhance(image, rules) do
    div = case length(image) do
            size when rem(size, 2) === 0 -> 2
            size when rem(size, 3) === 0 -> 3
          end

    extract_squares(image, div)
    |> Enum.map(fn square ->
      Map.get(rules, square)
    end)
    |> combine
  end

  defp extract_squares(image, div) do
    size = length(image)
    parts = div(size, div)
    Enum.chunk_every(image, div)
    |> Enum.flat_map(fn rows ->
      Enum.map(rows, fn row ->
        mask = (1 <<< div) - 1
        Enum.map(parts - 1 .. 0, fn part_num ->
          shift = part_num * div
          (row >>> shift) &&& mask
        end)
      end)
    end)
    |> transpose
    |> List.flatten
    |> Enum.chunk_every(div)
  end

  defp combine(fragments) do
    size = length(fragments)
    side = round(:math.sqrt(size))
    shift = length(hd(fragments))

    fragments
    |> Enum.chunk_every(side)
    |> Enum.map(&List.flatten/1)
    |> transpose
    |> Enum.map(fn column ->
      Enum.reduce(column, 0, fn pixels, acc ->
        (acc <<< shift) ||| pixels
      end)
    end)
  end

  defp transpose(lists) do
    Enum.zip(lists)
    |> Enum.map(&Tuple.to_list/1)
  end

  defp starter_image() do
    ".#./..#/###" |> parse_pattern
  end

  defp all_poses(image) do
    rot1 = rot90(image)
    rot2 = rot90(rot1)
    rot3 = rot90(rot2)
    flip0 = Enum.reverse(image)
    flip1 = rot90(flip0)
    flip2 = rot90(flip1)
    flip3 = rot90(flip2)
    [image, rot1, rot2, rot3, flip0, flip1, flip2, flip3]
    |> Enum.uniq
  end

  def rot90(pixels) do
    Enum.reduce(0..length(pixels) - 1, [], fn column, acc ->
      [extract_column(pixels, 1 <<< column) | acc]
    end)
  end

  def extract_column(pixels, mask) do
    Enum.reverse(pixels)
    |> Enum.reduce(0, fn int, acc ->
      (acc <<< 1) ||| extract_bit(int, mask)
    end)
  end

  defp extract_bit(int, mask) do
    case int &&& mask do
      0 -> 0
      _ -> 1
    end
  end

  defp count_ones(image) do
    Enum.reduce(image, 0, fn n, acc ->
      count_ones(n, acc)
    end)
  end

  defp count_ones(0, count), do: count
  defp count_ones(n, count) do
    if (n &&& 1) === 1 do
      count_ones(n >>> 1, count + 1)
    else
      count_ones(n >>> 1, count)
    end
  end

  defp parse(input) do
    Enum.flat_map(input, fn rule ->
      [left, right] = String.split(rule, " => ")
      left = parse_pattern(left)
      right = parse_pattern(right)
      Enum.map(all_poses(left), fn pat ->
        {pat, right}
      end)
    end)
  end

  defp parse_pattern(pattern) do
    String.split(pattern, "/")
    |> Enum.map(fn pattern ->
      Enum.reduce(String.to_charlist(pattern), 0, fn pixel, acc ->
        (acc <<< 1) |||
          case pixel do
            ?\# -> 1
            ?\. -> 0
          end
      end)
    end)
  end
end
