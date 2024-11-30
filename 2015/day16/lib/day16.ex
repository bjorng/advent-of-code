defmodule Day16 do
  def part1(input, tape) do
    tape = parse_tape(tape)
    parse(input)
    |> Enum.filter(fn {_, list} ->
      Enum.all?(tape, fn {item, amount} ->
        case List.keyfind(list, item, 0) do
          nil ->
            true
          {_, other_amount} ->
            amount === other_amount
        end
      end)
    end)
    |> hd
    |> elem(0)
  end

  def part2(input, tape) do
    tape = parse_tape(tape)
    parse(input)
    |> Enum.filter(fn {_, list} ->
      Enum.all?(tape, fn {item, amount} ->
        case List.keyfind(list, item, 0) do
          nil ->
            true
          {_, other_amount} ->
            case item do
              "cats" ->
                other_amount > amount
              "trees" ->
                other_amount > amount
              "pomeranians" ->
                other_amount < amount
              "goldfish" ->
                other_amount < amount
              _ ->
                other_amount === amount
            end
        end
      end)
    end)
    |> hd
    |> elem(0)
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      ["Sue", n | rest] = String.split(line, ~r/[:, ]+/)
      n = String.to_integer(n)
      list = rest
      |> Enum.chunk_every(2)
      |> Enum.map(fn [item, amount] ->
        {item, String.to_integer(amount)}
      end)
      {n, list}
    end)
  end

  defp parse_tape(tape) do
    Enum.map(tape, fn line ->
      [item, amount] = String.split(line, ~r/[:, ]+/)
      {item, String.to_integer(amount)}
    end)
  end
end
