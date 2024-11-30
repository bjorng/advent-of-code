defmodule Day03 do
  def part1(input) do
    grid = parse(input)
    Enum.flat_map(grid, fn {position, item} ->
      case item do
        {:symbol, _} ->
          []
        {n, _} when is_integer(n) ->
          case adjacent_symbols(grid, position) do
            [] ->
              []
            [_|_] ->
              [n]
          end
      end
    end)
    |> Enum.sum
  end

  def part2(input) do
    grid = parse(input)
    Enum.flat_map(grid, fn {position, item} ->
      case item do
        {:symbol, _} ->
          []
        {n, _} when is_integer(n) ->
          adjacent_symbols(grid, position)
          |> Enum.map(&{&1, n})
      end
    end)
    |> Enum.group_by(fn {key, _} -> key end)
    |> Enum.flat_map(fn {_, list} ->
      case list do
        [{_, n1}, {_, n2}] ->
          [n1 * n2]
        _ ->
          []
      end
    end)
    |> Enum.sum
  end

  defp adjacent_symbols(grid, {row, col} = position) do
    {_, {_, end_col}} = grid[position]
    Enum.map(col..end_col, &{row, &1})
    |> Enum.flat_map(&adjacent/1)
    |> Enum.uniq
    |> Enum.flat_map(fn position ->
      case grid do
        %{^position => {:symbol, _}} ->
          [position]
        %{} ->
          []
      end
    end)
    |> Enum.uniq
  end

  defp adjacent({row, col}) do
    [{row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
     {row, col - 1},                     {row, col + 1},
     {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}]
  end

  defp parse(input) do
    input
    |> Enum.with_index(&parse_line/2)
    |> Enum.concat
    |> Map.new
  end

  defp parse_line(line, row) do
    parse_line(line, row, 0)
  end

  defp parse_line(line, row, col) do
    case line do
      <<".", line::binary>> ->
        parse_line(line, row, col + 1)
      <<digit, _::binary>> when digit in ?0..?9 ->
        {n, new_line} =  Integer.parse(line)
        num_digits = byte_size(line) - byte_size(new_line)
        end_position = {row, col + num_digits - 1}
        [{{row, col}, {n, end_position}} | parse_line(new_line, row, col + num_digits)]
      <<symbol, line::binary>> ->
        [{{row, col}, {:symbol, symbol}} | parse_line(line, row, col + 1)]
      <<>> ->
        []
    end
  end
end
