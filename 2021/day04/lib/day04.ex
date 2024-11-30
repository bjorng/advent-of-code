defmodule Day04 do
  use Bitwise

  def part1(input) do
    {numbers, boards} = parse(input)
    boards = prepare_boards(boards)
    Enum.reduce_while(numbers, boards, fn n, acc ->
      acc =
        Enum.map(acc, fn board ->
          update_board(board, n)
        end)
      case winning_boards(acc) do
        [] ->
          {:cont, acc}
        [board] ->
          {:halt, score(board, n)}
      end
    end)
  end

  def part2(input) do
    {numbers, boards} = parse(input)
    boards = prepare_boards(boards)
    Enum.reduce_while(numbers, boards, fn n, acc ->
      acc =
        Enum.map(acc, fn board ->
          update_board(board, n)
        end)
      case winning_boards(acc) do
        [] ->
          {:cont, acc}
        [_|_] = winning_boards ->
          case acc do
            [_] ->
              [winning_board] = winning_boards
              {:halt, score(winning_board, n)}
            [_|_] ->
              {:cont, remove_winning(acc, winning_boards)}
          end
      end
    end)
  end

  defp remove_winning(boards, winning_boards) do
    Enum.reject(boards, fn {map, _} ->
      Enum.any?(winning_boards, fn {winning_map, _} ->
        map === winning_map
      end)
    end)
  end

  defp prepare_boards(boards) do
    Enum.map(boards, &prepare_board/1)
  end

  defp prepare_board(board) do
    map = board
    |> Enum.with_index
    |> Enum.map(fn {line, row} ->
      line
      |> Enum.with_index
      |> Enum.map(fn {number, col} ->
        {number, {row, col}}
      end)
    end)
    |> Enum.concat
    |> Map.new
    {map, [0, 0, 0, 0, 0]}
  end

  defp update_board({map, grid} = board, n) do
    case Map.get(map, n) do
      nil ->
        board
      row_col ->
        {map, mark(grid, row_col)}
    end
  end

  defp mark(grid, {row, col}) do
    {prefix, [line|suffix]} = Enum.split(grid, row)
    line = line ||| (1 <<< col)
    prefix ++ [line|suffix]
  end

  defp winning_boards(boards) do
    Enum.filter(boards, &winning?/1)
  end

  defp winning?({_, grid}) do
    Enum.any?(grid, &(&1 == 0x1F)) ||
      Enum.reduce(grid, 0x1F, &(&1 &&& &2)) != 0
  end

  defp score(board, n) do
    sum = unmarked_sum(board)
    n * sum
  end

  defp unmarked_sum({map, grid}) do
    Enum.filter(map, fn {_, row_col} ->
      unmarked?(grid, row_col)
    end)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum
  end

  defp unmarked?(grid, {row, col}) do
    line = Enum.at(grid, row)
    (line &&& (1 <<< col)) == 0
  end

  defp parse(input) do
    [numbers | rest] = input
    numbers = numbers
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    boards = rest
    |> Enum.map(fn board_line ->
      board_line
      |> String.split
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.chunk_every(5)

    {numbers, boards}
  end
end
