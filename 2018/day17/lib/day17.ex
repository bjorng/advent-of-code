defmodule Day17 do
  def count_tiles lines do
    state = fill_tiles lines
    #print_state state
    {flowing, settled} =
      Enum.reduce(state.contents, {0, 0}, fn {_, tile_type}, {flowing, settled} ->
	case tile_type do
	  :flowing ->
	    {flowing + 1, settled}
	  :settled ->
	    {flowing, settled + 1}
	  _ ->
	    {flowing, settled}
	end
      end)
    #          part 2        part 1
    {flowing, settled, flowing + settled}
  end

  defp fill_tiles lines do
    ranges = parse_input lines
    state = build_state ranges
    min_row = Enum.min(state.row_range)
    spring = {min_row, 500}
    {:done, state} = fill_tile(state, spring)
    state
  end

  defp fill_tile state, {row, col} = pos do
    case at(state, pos) do
      :outside ->
	{:done, state}
      :clay ->
	{:blocked, state}
      :settled ->
	{:blocked, state}
      :free ->
	state = fill state, pos, :flowing
	next_row = {row + 1, col}
	case fill_tile(state, next_row) do
	  {:blocked, state} ->
	    case at(state, next_row) do
	      blocked when blocked in [:clay, :settled] ->
		case fill_horizontal(state, pos, -1) do
		  {:done, state} ->
		    fill_horizontal(state, pos, 1)
		  {:blocked, state} ->
		    case fill_horizontal(state, pos, 1) do
		      {:blocked, state} ->
			state = fill state, pos, :settled
			state = fill_settled state, pos, -1
			state = fill_settled state, pos, 1
			{:blocked, state}
		      {:done, state} ->
			{:done, state}
		    end
		end
	      _ ->
		{:done, state}
	    end
	  {:done, state} ->
	    {:done, state}
	end
    end
  end

  defp fill_horizontal state, {row, col}, direction do
    pos = {row, col + direction}
    case at(state, pos) do
      :outside ->
	{:done, state}
      :clay ->
	{:blocked, state}
      _ ->
	state = fill state, pos, :flowing
	case at(state, {row + 1, col + direction}) do
	  :clay ->
	    fill_horizontal state, pos, direction
	  :settled ->
	    fill_horizontal state, pos, direction
	  _ ->
	    fill_tile state, pos
	end
    end
  end

  defp fill_settled state, {row, col}, direction do
    pos = {row, col + direction}
    if state.contents[pos] == :flowing do
      state = fill state, pos, :settled
      fill_settled state, pos, direction
    else
      state
    end
  end

  defp fill state, pos, elem do
    contents = Map.put(state.contents, pos, elem)
    %{state | contents: contents}
  end

  defp at state, {row, _} = pos do
    case state.contents[pos] do
      :clay -> :clay
      :settled -> :settled
      :flowing -> :free
      nil ->
	case row in state.row_range do
	  true -> :free
	  false -> :outside
	end
    end
  end

  defp build_state ranges do
    row_range = Stream.map(ranges, fn {row_range, _} -> row_range end)
    |> Enum.reduce(fn row_range, row_range0 ->
      %Range{first: min_row0, last: max_row0} = row_range0
      %Range{first: min_row, last: max_row} = row_range
      (min(min_row0, min_row))..(max(max_row0, max_row))
    end)
    map = for {rows, cols} <- ranges,
      row <- rows,
      col <- cols,
      into: %{}
      do {{row, col}, :clay}
    end
    %{row_range: row_range, contents: map}
  end

  defp parse_input lines do
    Enum.map(lines, &parse_line/1)
  end

  defp parse_line line do
    re = ~r/^([xy])=(\d+), ([xy])=(\d+)[.][.](\d+)$/
    [v1, val, v2, min, max] = Regex.run re, line, capture: :all_but_first
    {val, min,  max} = {String.to_integer(val), String.to_integer(min), String.to_integer(max)}
    [{"x", x_range}, {"y", y_range}] = Enum.sort [{v1,val..val},{v2,min..max}]
    {y_range, x_range}
  end

  def print_state state do
    contents = state.contents
    IO.puts ""
    row_range = state.row_range
    {min_col, max_col} = Enum.reduce(state.contents, {:infinity, 0},
      fn {{_, col}, _}, {min_col, max_col} ->
	{min(col, min_col), max(col, max_col)}
      end)
    col_range = min_col..max_col

    IO.puts Enum.map(col_range, fn col ->
      if col == 500, do: ?+, else: ?.
    end)

    Enum.each(row_range, fn row ->
      IO.puts Enum.map(col_range, fn col ->
	pos = {row, col}
	case contents[pos] do
	  nil -> ?.
	  :clay -> ?\#
	  :flowing -> ?|
	  :settled -> ?\~
	end
      end)
    end)
  end

end
