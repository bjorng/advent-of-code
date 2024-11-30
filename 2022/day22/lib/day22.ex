defmodule Day22 do
  def part1(input) do
    {commands, grid} = parse(input)
    {grid, position, wrap} = prepare_grid(grid, false)
    facing = 0
    {{row, col}, facing} = execute_commands(commands, position, facing, grid, wrap)
    1000 * row + 4 * col + facing
  end

  def part2(input) do
    {commands, grid} = parse(input)
    {grid, position, wrap} = prepare_grid(grid, true)
    facing = 0
    {{row, col}, facing} = execute_commands(commands, position, facing, grid, wrap)
    1000 * row + 4 * col + facing
  end

  defp prepare_grid(grid, cube_wrapping?) do
    {{max_row, _}, _} =
      Enum.max_by(grid, fn {{row, _}, _} -> row end)
    {{_, max_col}, _} =
      Enum.max_by(grid, fn {{_, col}, _} -> col end)
    grid = grid
    |> Enum.reject(fn {_, item} -> item === :blank end)
    |> Map.new
    {position, _} = Enum.min(grid)
    wrap = case cube_wrapping? do
             true ->
               wrap_fn_3d(max_row, max_col)
             false ->
               wrap_fn_2d(max_row, max_col)
           end
    {grid, position, wrap}
  end

  defp wrap_fn_2d(max_row, max_col) do
    fn position, facing ->
      case position do
        {row, col} when row === 0 ->
          {{max_row + 1, col}, facing}
        {row, col} when row > max_row ->
          {{0, col}, facing}
        {row, col} when col === 0 ->
          {{row, max_col + 1}, facing}
        {row, col} when col > max_col ->
          {{row, 0}, facing}
        _ ->
          {position, facing}
      end
    end
  end

  defp wrap_fn_3d(12, 16) do
    size = 4
    fn position, facing ->
      {row, col} = position
      # . . a .
      # d c b .
      # . . e f
      cond do
        row in size+1 .. 2*size and col === 3 * size + 1 and facing === 0 ->
          # Face b facing right; move to face f facing down
          {{2 * size + 1, 5 * size - row + 1}, 1}
        row === 3 * size + 1 and col in 2*size+1..3*size and facing === 1 ->
          # Face e facing down; move to face d facing up
          {{2 * size, 3 * size - col + 1}, 3}
        row === size and col in size+1..2*size and facing === 3 ->
          # Face c facing up; move to face a facing right
          {{col - size, 2 * size + 1}, 0}
      end
    end
  end
  defp wrap_fn_3d(200, 150) do
    fn position, facing ->
      {new_position, new_facing} = do_wrap_3d(position, facing)
      facing_back = rem(new_facing + 2, 4)
      move_back = add(new_position, facing_to_direction(facing_back))
      move_back_facing = rem(facing + 2, 4)
      {move_back, ^move_back_facing} = do_wrap_3d(move_back, facing_back)
      ^position = add(move_back, facing_to_direction(facing))
      {new_position, new_facing}
    end
  end

  defp do_wrap_3d(position, facing) do
      size = 50
      {row, col} = position
      # . a b
      # . c .
      # d e .
      # f . .
      cond do
        row === 0 and col in size+1..2*size and facing === 3 ->
          # Face a facing up; move to face f facing right
          {{col + 2 * size, 1}, 0}
        row in 1..size and col === 50 and facing === 2 ->
          # Face a facing left; move to face d facing right
          {{3 * size - row + 1, 1}, 0}
        row === 0 and col in 2*size+1..3*size and facing === 3 ->
          # Face b facing up; move to f facing up
          {{4 * size, col - 2 * size}, 3}
        row in 1..size and col === 3 * size + 1 and facing === 0 ->
          # Face b facing right; move to face e facing left
          {{3 * size - row + 1, 2 * size}, 2}
        row === size + 1 and col in 2*size+1..3*size and facing === 1 ->
          # Face b facing down; move to face c facing left
          {{col - size, 2 * size}, 2}
        row in size+1..2*size and col == 50 and facing == 2 ->
          # Face c facing left; move to d facing down
          {{2 * size + 1, row - size}, 1}
        row in size+1..2*size and col === 2 * size + 1 and facing === 0 ->
          # Face c facing right; move to b facing up
          {{size, row + size}, 3}
        row in 2*size+1..3*size and col === 0 and facing === 2 ->
          # Face d facing left; move to face a facing right
          {{3 * size - row + 1, 51}, 0}
        row === 2*size and col in 1..size and facing === 3 ->
          # Face d facing up; move to face c facing right
          {{size + col, 51}, 0}
        row in 2*size+1..3*size and col === 2 * size + 1 and facing === 0 ->
          # Face e facing right; move to b facing left
          {{3 * size - row + 1, 3 * size}, 2}
        row === 3 * size + 1 and col in size+1..2*size and facing === 1 ->
          # Face e facing down; move to face f facing left
          {{col + 2 * size, size}, 2}
        row in 3*size+1..4*size and col === 0 and facing === 2 ->
          # Face f facing left; move to face a facing down
          {{1, row - 2 * size}, 1}
        row === 4 * size + 1 and facing === 1 ->
          # Face f facing down; move to face b facing down
          {{1, col + 2 * size}, 1}
        row in 3*size+1..4*size and col == size + 1 and facing === 0 ->
          # Face f facing right; move to face e facing up
          {{3 * size, row - 2 * size}, 3}
      end
  end

  defp execute_commands(commands, position, facing, grid, wrap) do
    Enum.reduce(commands, {position, facing}, fn command, state ->
      execute_command(command, state, grid, wrap)
    end)
  end

  defp execute_command(command, {position, facing}, grid, wrap) do
    case command do
      :left ->
        {position, rotate_left(facing)}
      :right ->
        {position, rotate_right(facing)}
      n when is_integer(n) ->
        move_direction(n, position, facing, grid, wrap)
    end
  end

  defp move_direction(0, position, facing, _grid, _wrap) do
    {position, facing}
  end
  defp move_direction(n, position, facing, grid, wrap) do
    case move(position, facing, grid, wrap) do
      :error ->
        {position, facing}
      {:ok, position, facing} ->
        move_direction(n - 1, position, facing, grid, wrap)
    end
  end

  defp move(position, facing, grid, wrap) do
    {position, facing} = move_grid(position, facing, grid, wrap)
    case grid do
      %{^position => :wall} ->
        :error
      %{^position => :empty} ->
        {:ok, position, facing}
    end
  end

  defp move_grid(position, facing, grid, wrap) do
    position = add(position, facing_to_direction(facing))
    case Map.has_key?(grid, position) do
      true ->
        {position, facing}
      false ->
        {position, facing} = wrap.(position, facing)
        case Map.has_key?(grid, position) do
          true ->
            {position, facing}
          false ->
            move_grid(position, facing, grid, wrap)
        end
    end
  end

  defp add({row, col}, {row_delta, col_delta}) do
    {row + row_delta, col + col_delta}
  end

  defp rotate_left(facing) do
    rem(facing + 3, 4)
  end

  defp rotate_right(facing) do
    rem(facing + 1, 4)
  end

  defp facing_to_direction(facing) do
    case facing do
      0 -> {0, 1}
      1 -> {1, 0}
      2 -> {0, -1}
      3 -> {-1, 0}
      :right -> {0, 1}
      :down -> {1, 0}
      :left -> {0, -1}
      :up -> {-1, 0}
    end
  end

  defp parse(input) do
    [commands | grid] = Enum.reverse(input)
    grid = Enum.reverse(grid)
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index(1)
      |> Enum.map(fn {char, col} ->
        char = case char do
                 ?\# -> :wall
                 ?. -> :empty
                 ?\s -> :blank
               end
        {{row, col}, char}
      end)
    end)
    commands = parse_commands(commands)
    {commands, grid}
  end

  defp parse_commands(""), do: []
  defp parse_commands(commands) do
    case Integer.parse(commands) do
      :error ->
        case commands do
          "L" <> commands -> [:left | parse_commands(commands)]
          "R" <> commands -> [:right | parse_commands(commands)]
        end
      {amount, commands} ->
        [amount | parse_commands(commands)]
    end
  end
end
