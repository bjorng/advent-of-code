defmodule Day06 do
  def part1(input) do
    parse(input)
    |> Day06Part1.solve
  end

  def part2(input) do
    parse(input)
    |> Day06Part2.solve
  end

  defp parse(input) do
    InstructionParser.parse(input)
  end
end

defmodule Day06Part1 do
  use Bitwise

  def solve(input) do
    input
    |> Enum.reduce(make_grid(), fn instruction, acc ->
      case instruction do
        {:turn_on, coordinates} ->
          update_lights(acc, coordinates, fn row_bits, active_bits ->
            row_bits ||| active_bits
          end)
        {:turn_off, coordinates} ->
          update_lights(acc, coordinates, fn row_bits, active_bits ->
            row_bits &&& bnot(active_bits)
          end)
        {:toggle, coordinates} ->
          update_lights(acc, coordinates, fn row_bits, active_bits ->
            bxor(row_bits, active_bits)
          end)
      end
    end)
    |> count_lights
  end

  defp make_grid() do
    %{}
  end

  defp update_lights(grid, coordinates, update) do
    {{upper_row, left_col}, {lower_row, right_col}} = coordinates
    bit_range = left_col..right_col
    Enum.reduce(upper_row..lower_row, grid, fn row, acc ->
      num_bits = bit_range.last - bit_range.first + 1
      active_bits = (((1 <<< num_bits) - 1) <<< bit_range.first)
      row_bits = Map.get(acc, row, 0)
      row_bits = update.(row_bits, active_bits)
      Map.put(acc, row, row_bits)
    end)
  end

  defp count_lights(grid) do
    Map.values(grid)
    |> Enum.reduce(0, fn row, acc ->
      acc + count_bits(row)
    end)
  end

  defp count_bits(n), do: count_bits(n, 0)

  defp count_bits(0, acc), do: acc
  defp count_bits(n, acc) do
    count_bits(n &&& (n - 1), acc + 1)
  end
end

defmodule Day06Part2 do
  def solve(input) do
    grid = make_grid()
    Enum.each(input, fn instruction ->
      case instruction do
        {:turn_on, coordinates} ->
          update_lights(grid, coordinates, fn value ->
            value + 1
          end)
        {:turn_off, coordinates} ->
          update_lights(grid, coordinates, fn value ->
            max(value - 1, 0)
          end)
        {:toggle, coordinates} ->
          update_lights(grid, coordinates, fn value ->
            value + 2
          end)
      end
    end)
    count_lights(grid)
  end

  defp make_grid() do
    :counters.new(1000 * 1000, [])
  end

  defp update_lights(grid, coordinates, update) do
    {{upper_row, left_col}, {lower_row, right_col}} = coordinates
    Enum.each(upper_row..lower_row, fn row ->
      Enum.each(left_col..right_col, fn col ->
        key = row * 1000 + col + 1
        :counters.put(grid, key, update.(:counters.get(grid, key)))
      end)
    end)
  end

  defp count_lights(grid) do
    Enum.reduce(1..1000*1000, 0, fn key, acc ->
      acc + :counters.get(grid, key)
    end)
  end
end

defmodule InstructionParser do
  import NimbleParsec

  defp pack_coordinate([x, y]) do
    {x, y}
  end

  defp pack_pair([coord1, coord2]) do
    {coord1, coord2}
  end

  defp pack([coordinates], operation) do
    {operation, coordinates}
  end

  blanks = ascii_string([?\s], min: 1)

  coordinate = integer(min: 1)
  |> ignore(string(","))
  |> integer(min: 1)
  |> reduce({:pack_coordinate, []})

  two_coordinates = coordinate
  |> ignore(blanks)
  |> ignore(string("through"))
  |> ignore(blanks)
  |> concat(coordinate)
  |> reduce({:pack_pair, []})

  turn_on = ignore(string("turn on"))
  |> ignore(blanks)
  |> concat(two_coordinates)
  |> reduce({:pack, [:turn_on]})

  turn_off = ignore(string("turn off"))
  |> ignore(blanks)
  |> concat(two_coordinates)
  |> reduce({:pack, [:turn_off]})

  toggle = ignore(string("toggle"))
  |> ignore(blanks)
  |> concat(two_coordinates)
  |> reduce({:pack, [:toggle]})

  defparsecp :main,
    choice([turn_on, turn_off, toggle])
    |> eos()

  def parse(input) do
    Enum.map(input, fn(line) ->
      {:ok, [res], _, _, _, _} = main(line)
      res
    end)
  end
end
