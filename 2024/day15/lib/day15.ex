defmodule Day15 do
  def part1(input) do
    {grid, moves} = parse(input)
    {grid, robot} = parse_grid(grid)

    solve(grid, robot, moves)
  end

  defp push_boxes_part1(grid, position, move) do
    next = add(position, move)
    case grid do
      %{^next => ?\#} ->
        grid
      %{^next => ?.} ->
        %{grid | position => ?., next => ?O}
      %{^next => ?O} ->
        case find_empty(grid, next, move) do
          nil ->
            grid
          empty ->
            %{grid | position => ?., empty => ?O}
        end
    end
  end

  defp find_empty(grid, pos, move) do
    case Map.fetch!(grid, pos) do
      ?. -> pos
      ?\# -> nil
      ?O -> find_empty(grid, add(pos, move), move)
    end
  end

  def part2(input) do
    {grid, moves} = parse(input)
    grid = widen(grid)
    {grid, robot} = parse_grid(grid)

    solve(grid, robot, moves)
  end

  def solve(grid, robot, moves) do
    Enum.reduce(moves, {grid, robot}, fn move, {grid, robot} ->
      next = add(robot, move)
      case Map.fetch!(grid, next) do
        ?. ->
          {grid, next}
        ?\# ->
          {grid, robot}
        ?O ->
          # Part 1
          grid = push_boxes_part1(grid, next, move)
          if Map.fetch!(grid, next) === ?. do
            {grid, next}
          else
            {grid, robot}
          end
        char when char in [?\[, ?\]] ->
          # Part 2
          case push_boxes_part2(grid, next, move) do
            nil -> {grid, robot}
            grid -> {grid, next}
          end
      end
    end)
    |> elem(0)
    |> Enum.map(fn {{row, col}, what} ->
      if what in [?O, ?\[] do
        100 * row + col
      else
        0
      end
    end)
    |> Enum.sum
  end

  defp push_boxes_part2(grid, position, {0, _} = move) do
    next1 = add(position, move)
    next2 = add(next1, move)

    move_box = fn grid ->
      %{grid | next2 => grid[next1],
        next1 => grid[position],
        position => ?.}
    end

    case Map.fetch!(grid, next2) do
      ?\# ->
        nil
      ?. ->
        move_box.(grid)
      char when char in [?\[, ?\]] ->
        case push_boxes_part2(grid, next2, move) do
          nil -> nil
          grid -> move_box.(grid)
        end
    end
  end
  defp push_boxes_part2(grid, position, {_, 0} = move) do
    {position1, position2} =
      case Map.fetch!(grid, position) do
        ?\[ ->
          {position, add(position, {0, 1})}
        ?\] ->
          {add(position, {0, -1}), position}
      end
    next1 = add(position1, move)
    next2 = add(position2, move)

    move_box = fn grid ->
      %{grid | position1 => ?., position2 => ?.,
        next1 => ?\[, next2 => ?\]}
    end

    push = fn position ->
      case push_boxes_part2(grid, position, move) do
        nil -> nil
        grid -> move_box.(grid)
      end
    end

    case [Map.fetch!(grid, next1), Map.fetch!(grid, next2)] do
      ~c".." ->
        move_box.(grid)
      ~c"[]" ->
        push.(next1)
      ~c".\[" ->
        push.(next2)
      ~c"\]." ->
        push.(next1)
      ~c"\]\[" ->
        case push_boxes_part2(grid, next1, move) do
          nil ->
            nil
          grid ->
            case push_boxes_part2(grid, next2, move) do
              nil -> nil
              grid -> move_box.(grid)
            end
        end
      [a, b] when a === ?\# or b === ?\# ->
        nil
    end
  end

  defp widen(grid) do
    Enum.map(grid, fn line ->
      :binary.replace(line, "#", "##", [:global])
      |> :binary.replace("O", "[]", [:global])
      |> :binary.replace(".", "..", [:global])
      |> :binary.replace("@", "@.", [:global])
    end)
  end

  defp parse(input) do
    [grid, moves] = String.split(input, "\n\n", trim: true)
    |> Enum.map(&String.trim/1)

    grid = String.split(grid, "\n", trim: true)

    moves = moves
    |> String.to_charlist
    |> Enum.flat_map(fn c ->
      case c do
        ?^ -> [{-1, 0}]
        ?v -> [{1, 0}]
        ?< -> [{0, -1}]
        ?> -> [{0, 1}]
        ?\n -> []
      end
    end)

    {grid, moves}
  end

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp parse_grid(grid) do
    grid = grid
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        [{position, char}]
      end)
    end)
    |> Map.new

    {robot, ?@} = Enum.find(grid, fn {_, what} ->
      what === ?@
    end)

    grid = Map.put(grid, robot, ?.)

    {grid, robot}
  end

  def print_grid({map, robot}) do
    :io.nl
    {{min_row, _}, {max_row, _}} = Enum.min_max_by(Map.keys(map), &elem(&1, 0))
    {{_, min_col}, {_, max_col}} = Enum.min_max_by(Map.keys(map), &elem(&1, 1))
    Enum.each(min_row..max_row, fn row ->
      Enum.each(min_col..max_col, fn col ->
        position = {row, col}
        if position === robot do
          :io.put_chars("@")
        else
          :io.put_chars([Map.fetch!(map, position)])
        end
      end)
      :io.nl
    end)
    :io.nl
    {map, robot}
  end
end
