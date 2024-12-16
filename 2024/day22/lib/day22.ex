defmodule Day22 do
  import Bitwise

  def part1(input) do
    parse(input)
    |> Enum.map(fn secret ->
      secret
      |> Stream.iterate(&next_secret/1)
      |> Stream.drop(2000)
      |> Enum.take(1)
      |> hd
    end)
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.reduce(%{}, fn secret, sales ->
      secret
      |> Stream.iterate(&next_secret/1)
      |> Stream.map(&rem(&1, 10))
      |> Stream.chunk_every(2, 1)
      |> Stream.map(fn [a, b] -> {b - a, b} end)
      |> Enum.take(2000)
      |> Enum.chunk_every(4, 1, :discard)
      |> Enum.flat_map(fn seq ->
          [_, _, _, {_, price}] = seq
        # Optimization: compress the sequence.
        seq = Enum.map(seq, &elem(&1, 0))
        |> Enum.reduce(0, fn item, acc ->
          acc * 20 + (item + 10)
        end)
        [{seq, price}]
      end)
      |> Enum.uniq_by(&elem(&1, 0))
      |> Enum.reduce(sales, fn {seq, price}, sales ->
        Map.update(sales, seq, price, &(&1 + price))
      end)
    end)
    |> Enum.max_by(fn {_, total_price} -> total_price end)
    |> elem(1)
  end

  defp next_secret(secret) do
    mask = 16777216 - 1
    secret = band(bxor(secret <<< 6, secret), mask)
    secret = band(bxor(secret >>> 5, secret), mask)
    band(bxor(secret <<< 11, secret), mask)
  end

  defp parse(input) do
    input
    |> Enum.map(&String.to_integer/1)
  end
end
