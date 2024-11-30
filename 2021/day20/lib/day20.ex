defmodule Day20 do
  def part1(input) do
    solve(input, 2)
  end

  def part2(input) do
    solve(input, 50)
  end

  def solve(input, steps) do
    {algorithm, image} = parse(input)

    Enum.reduce(1..steps, image, fn _, image ->
      enhance(image, algorithm)
    end)
    |> elem(0)
    |> Enum.reduce(0, fn {_, pixel}, acc ->
      acc + pixel
    end)
  end

  defp enhance({image, default}, algorithm) do
    image = expand(image, default)
    image =
      Enum.map(image, fn {key, _pixel} ->
        algo_key =
          Enum.reduce(neighbors(key), 0, fn key, acc ->
            acc * 2 + Map.get(image, key, default)
          end)
        {key, Map.fetch!(algorithm, algo_key)}
      end)
      |> Map.new

    default = Map.fetch!(algorithm, default)
    {image, default}
  end

  defp expand(image, default) do
    Enum.reduce(image, image, fn {key, _}, acc ->
      ns = neighbors(key)
      Enum.reduce(ns, acc, fn key, acc ->
        if Map.has_key?(acc, key) do
          acc
        else
          Map.put(acc, key, default)
        end
      end)
    end)
  end

  defp neighbors({row, col}) do
    [{row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
     {row, col - 1},     {row, col},     {row, col + 1},
     {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}]
  end

  def print_grid({image, default}) do
    Enum.map(-10..10, fn row ->
        [Enum.map(-10..10, fn col ->
          case Map.get(image, {row, col}, 0) do
            0 -> ?\.
            1 -> ?\#
          end
        end), "\n"]
    end)
    |> IO.puts
    {image, default}
  end

  defp parse([algorithm | image]) do
    image = image
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.codepoints(line)
      |> Enum.with_index
      |> Enum.map(fn {char, col} ->
        key = {row, col}
        case char do
          "." -> {key, 0}
          "#" -> {key, 1}
        end
      end)
    end)
    |> Map.new

    512 = String.length(algorithm)
    algorithm = algorithm
    |> String.codepoints
    |> Enum.with_index
    |> Enum.map(fn {char, index} ->
      case char do
        "." -> {index, 0}
        "#" -> {index, 1}
      end
    end)
    |> Map.new()

    default = 0
    {algorithm, {image, default}}
  end
end
