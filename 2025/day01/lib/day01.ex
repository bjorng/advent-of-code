defmodule Day01 do
  def part1(input) do
    parse(input)
    |> Enum.scan(50, &(Integer.mod(&1 + &2, 100)))
    |> Enum.count(&(&1 === 0))
  end

  def part2(input) do
    parse(input)
    |> Enum.reduce({50, 0}, fn amount, {dial, crossings} ->
      new_dial = dial + rem(amount, 100)

      crossings = crossings + div(abs(amount), 100)

      crossings = cond do
        dial === 0 ->
          crossings
        new_dial === 0 or new_dial === 100 ->
          crossings
        new_dial in 1..99 ->
          crossings
        true ->
          crossings + 1
      end

      new_dial = Integer.mod(new_dial, 100)
      crossings = if new_dial === 0 do
        crossings + 1
      else
        crossings
      end
      {new_dial, crossings}
    end)
    |> then(&elem(&1, 1))
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      case line do
        "L" <> int -> -String.to_integer(int)
        "R" <> int -> String.to_integer(int)
      end
    end)
  end
end
