defmodule Day23 do
  def part1(input) do
    elfs = parse(input)
    Stream.unfold({elfs, directions()}, &next_round/1)
    |> Stream.drop(9)
    |> Enum.take(1)
    |> hd
    |> progress
  end

  def part2(input) do
    elfs = parse(input)
    1 + (Stream.unfold({elfs, directions()}, &next_round/1)
    |> Enum.count)
  end


  defp progress(elfs) do
    {{min_row, _}, {max_row, _}} = Enum.min_max_by(elfs, &elem(&1, 0))
    {{_, min_col}, {_, max_col}} = Enum.min_max_by(elfs, &elem(&1, 1))
    {min_row..max_row, min_col..max_col}
    Enum.reduce(min_row..max_row, 0, fn row, sum ->
      sum + Enum.count(min_col..max_col, fn col ->
        not MapSet.member?(elfs, {row, col})
      end)
    end)
  end

  defp next_round({elfs, directions}) do
    moves =
      Enum.flat_map(elfs, fn elf ->
        propose(elf, directions, elfs)
      end)
      |> Enum.group_by(&elem(&1, 0))
      |> Enum.flat_map(fn {_, list} ->
        case list do
           [_] -> list
           _ -> []
        end
      end)
      case moves do
        [] ->
          nil
        [_ | _] ->
          elfs =
            Enum.reduce(moves, elfs, fn {new, old}, elfs ->
              MapSet.delete(elfs, old)
              |> MapSet.put(new)
            end)
          directions = tl(directions) ++ [hd(directions)]
          {elfs, {elfs, directions}}
      end
  end

  defp propose(elf, directions, elfs) do
    case any_neighbor?(elf, elfs) do
      false ->
        []
      true ->
          Enum.find_value(directions, fn directions ->
            any_elf? =
              Enum.any?(directions, fn direction ->
                MapSet.member?(elfs, add(elf, direction))
              end)
            case any_elf? do
              true -> nil
              false -> [{add(elf, hd(directions)), elf}]
            end
          end) || []
    end
  end

  defp any_neighbor?(elf, elfs) do
    directions = [{-1, 1}, {-1, 0}, {-1, -1},
                  {0, 1}, {0, -1},
                  {1, 1}, {1, 0}, {1, -1}]
    Enum.any?(directions, fn direction ->
      MapSet.member?(elfs, add(elf, direction))
    end)
  end

  defp directions() do
    [[{-1, 0}, {-1, 1}, {-1, -1}],
     [{1, 0}, {1, 1}, {1, -1}],
     [{0, -1}, {-1, -1}, {1, -1}],
     [{0, 1}, {-1, 1}, {1, 1}]]
  end

  defp add({row, col}, {row_delta, col_delta}) do
    {row + row_delta, col + col_delta}
  end

  defp parse(input) do
    input
    |> Enum.with_index
    |> Enum.reduce([], fn
      {line, row}, grid ->
        String.to_charlist(line)
        |> Enum.with_index
        |> Enum.reduce(grid, fn {item, col}, grid ->
        case item do
          ?\# -> [{row, col} | grid]
          ?\. -> grid
        end
      end)
    end)
    |> MapSet.new
  end
end
