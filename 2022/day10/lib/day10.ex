defmodule Day10 do
  def part1(input) do
    input
    |> cycle_values
    |> Enum.filter(fn {cycle, _value} ->
      cycle in 20..220//40
    end)
    |> Enum.map(fn {cycle, value} -> cycle * value end)
    |> Enum.sum
  end

  def part2(input) do
    IO.puts("")
    input
    |> cycle_values
    |> Enum.map(fn {cycle, position} ->
      hpos = rem(cycle - 1, 40)
      if hpos in (position-1)..(position+1) do
        ?\#
      else
        ?.
      end
    end)
    |> Enum.chunk_every(40)
    |> Enum.intersperse('\n')
    |> IO.write
    IO.puts("")
  end

  defp cycle_values(input) do
    state = %{x: 1, cycle: 1}
    parse(input)
    |> Enum.flat_map_reduce(state, fn instruction, state ->
      %{x: x, cycle: cycle} = state
      case instruction do
        :noop ->
          state = %{state | cycle: cycle + 1}
          {[{cycle, x}], state}
        {:addx, increment} ->
          state = %{state | cycle: cycle + 2, x: x + increment}
          {[{cycle, x}, {cycle + 1, x}], state}
      end
    end)
    |> elem(0)
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      case String.split(line) do
        ["addx", number] ->
          {:addx, String.to_integer(number)}
        ["noop"] ->
          :noop
      end
    end)
  end
end
