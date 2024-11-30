defmodule Day23 do
  def part1(input) do
    solve(input)
  end

  def part2(input) do
    extra = ["  #D#C#B#A#", "  #D#B#A#C#"]
    {prefix, suffix} = Enum.split(input, 3)
    input = prefix ++ extra ++ suffix
    solve(input)
  end

  defp solve(input) do
    grid = parse(input)
    |> Map.new
    |> fix_already_home
    q = {:gb_sets.singleton({0, grid}), Map.new([{grid, 0}])}
    move(q)
  end

  defp move({q, seen_grids}) do
    {{energy, grid}, q} = :gb_sets.take_smallest(q)
    if won?(grid) do
      energy
    else
      q = do_move(grid, energy, {q, seen_grids})
      move(q)
    end
  end

  defp do_move(grid, energy, q) do
    Enum.reduce(grid, q, fn {pos, what}, q ->
      case what do
        {:pod, _, :home} ->
          q
        {:pod, _, _} ->
          move_pod(grid, pos, what, energy, q)
        _ ->
          q
      end
    end)
  end

  defp move_pod(grid, pos, pod, energy, q) do
    case walk_fun(grid, pod) do
      nil ->
        q
      walker ->
        grid = Map.put(grid, pos, update_pod_src(pos, pod))
        pod = update_pod_dst(pod)
        seen = MapSet.new()
        add_paths(grid, walker, pos, pod, energy, q, seen)
    end
  end

  defp add_paths(grid, walker, pos, pod, energy, q, seen) do
    seen = MapSet.put(seen, pos)
    neighbors(grid, pos)
    |> Enum.reduce(q, fn neighbor, {q, seen_grids} ->
      what = Map.fetch!(grid, neighbor)
      if MapSet.member?(seen, neighbor) do
        {q, seen_grids}
      else
        energy = energy + cost(pod)
        case walker.(neighbor, what) do
          :target ->
            updated_grid = Map.put(grid, neighbor, pod)
            cond do
              Map.get(seen_grids, updated_grid, :infinity) < energy ->
                {q, seen_grids}
              true ->
                seen_grids = Map.put(seen_grids, updated_grid, energy)
                q = :gb_sets.add({energy, updated_grid}, q)
                add_paths(grid, walker, neighbor, pod, energy, {q, seen_grids}, seen)
            end
          :pass ->
            add_paths(grid, walker, neighbor, pod, energy, {q, seen_grids}, seen)
          :blocked ->
            {q, seen_grids}
        end
      end
    end)
  end

  defp cost({:pod, pod_id, _}) do
    case pod_id do
      :'A' -> 1
      :'B' -> 10
      :'C' -> 100
      :'D' -> 1000
    end
  end

  defp walk_fun(_grid, {:pod, _, :unmoved}) do
    fn _pos, what ->
      case what do
        :empty -> :target
        nil -> :pass
        {:home, _} -> :pass
        _ -> :blocked
      end
    end
  end
  defp walk_fun(grid, {:pod, pod_id, :moved}) do
    case home_ok?(grid, pod_id) do
      nil ->
        nil
      home_pos ->
        fn pos, what ->
          case {pos, what} do
            {^home_pos, {:home, ^pod_id}} -> :target
            {_, {:home, ^pod_id}} -> :pass
            {_, :empty} -> :pass
            {_, nil} -> :pass
            {_, _} -> :blocked
          end
        end
    end
  end

  defp home_ok?(grid, pod_id) do
    col = pod_home_col(pod_id)
    home_ok?(grid, 2, col)
  end

  defp home_ok?(grid, row, col) do
    case Map.get(grid, {row, col}) do
      nil ->
        {row - 1, col}
      {:home, _} ->
        home_ok?(grid, row + 1, col)
      {:pod, _, :home} ->
        {row - 1, col}
      {:pod, _, :unmoved} ->
        nil
    end
  end

  defp update_pod_src(pos, pod) do
    case pod do
      {:pod, _, :unmoved} ->
        {:home, pod_home(pos)}
      {:pod, _, :moved} ->
        :empty
    end
  end

  defp update_pod_dst(pod) do
    case pod do
      {:pod, pod_id, :unmoved} ->
        {:pod, pod_id, :moved}
      {:pod, pod_id, :moved} ->
        {:pod, pod_id, :home}
    end
  end

  defp neighbors(grid, {row, col}) do
    [{row - 1, col},
     {row, col - 1}, {row, col + 1},
     {row + 1, col}]
     |> Enum.filter(fn pos ->
      case Map.get(grid, pos, :none) do
        :empty -> true
        {:home, _} -> true
        nil -> true
        _ -> false
      end
    end)
  end

  defp fix_already_home(grid) do
    Enum.reduce(col_range(), grid, fn col, grid ->
      pod_id = pod_home({2, col})
      row_range(grid)
      |> Enum.reverse
      |> Enum.reduce_while(grid, fn row, grid ->
        case Map.fetch!(grid, {row, col}) do
          {:pod, ^pod_id, :unmoved} ->
            {:cont, Map.put(grid, {row, col}, {:pod, pod_id, :home})}
          _ ->
            {:halt, grid}
        end
      end)
    end)
  end

  defp pod_home_col(pod_id) do
    case pod_id do
      :'A' -> 3
      :'B' -> 5
      :'C' -> 7
      :'D' -> 9
    end
  end

  defp pod_home({_, col}) do
    case col do
      3 -> :'A'
      5 -> :'B'
      7 -> :'C'
      9 -> :'D'
    end
  end

  defp won?(grid) do
    Enum.all?(row_range(grid), fn row ->
      Enum.all?(col_range(), fn col ->
        match?({:pod, _, :home}, Map.fetch!(grid, {row, col}))
      end)
    end)
  end

  defp row_range(grid) do
    if Map.has_key?(grid, {5, 3}), do: 2..5, else: 2..3
  end

  defp col_range(), do: 3..9//2

  defp parse(input) do
    Enum.with_index(input)
    |> Enum.flat_map(fn {line, row} ->
      Enum.with_index(String.codepoints(line))
      |> Enum.flat_map(fn {char, col} ->
        pos = {row, col}
        case char do
          "#" ->
            []
          "." ->
            if col in col_range() do
              [{pos, nil}]
            else
              [{pos, :empty}]
            end
          " " ->
            []
          _ ->
            [{pos, {:pod, String.to_atom(char), :unmoved}}]
        end
      end)
    end)
  end
end
