defmodule Day15 do
  import Bitwise

  def part1(input) do
    {genA, genB} = parse(input)
    part1(genA, genB)
  end

  def part1(genA, genB) do
    part1_count_pairs(genA, genB, 40_000_000, 0)
  end

  def part2(input) do
    {genA, genB} = parse(input)
    part2(genA, genB)
  end

  def part2(genA, genB) do
    part2_count_pairs(genA, genB, 5_000_000, 0)
  end

  defp part1_count_pairs(_genA, _genB, 0, count), do: count
  defp part1_count_pairs(genA, genB, limit, count) do
    divisor = 2147483647
    genA = rem(genA * 16807, divisor)
    genB = rem(genB * 48271, divisor)
    case band(genA, 0xffff) === band(genB, 0xffff) do
      true ->
	part1_count_pairs(genA, genB, limit - 1, count + 1)
      false ->
	part1_count_pairs(genA, genB, limit - 1, count)
    end
  end

  defp part2_count_pairs(_genA, _genB, 0, count), do: count
  defp part2_count_pairs(genA, genB, limit, count) do
    genA = nextA(genA)
    genB = nextB(genB)
    case band(genA, 0xffff) === band(genB, 0xffff) do
      true ->
	part2_count_pairs(genA, genB, limit - 1, count + 1)
      false ->
	part2_count_pairs(genA, genB, limit - 1, count)
    end
  end

  defp nextA(genA) do
    divisor = 2147483647
    genA = rem(genA * 16807, divisor)
    case band(genA, 3) do
      0 -> genA
      _ -> nextA(genA)
    end
  end

  defp nextB(genB) do
    divisor = 2147483647
    genB = rem(genB * 48271, divisor)
    case band(genB, 7) do
      0 -> genB
      _ -> nextB(genB)
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn gen ->
      [n] = Regex.run(~r"^Generator [AB] starts with (\d+)$",
      gen,
      [capture: :all_but_first])
      String.to_integer(n)
    end)
    |> List.to_tuple
  end
end
