defmodule Day22 do
  def part1(input) do
    {depth, target} = parse(input)
    #print_board depth, target
    risk_levels(depth, target)
    |> Stream.map(fn {_, level} -> level end)
    |> Enum.sum
  end

  def part2(input) do
    {depth, target} = parse(input)
    state = initial_state(depth, target)
    all_paths(state)
    |> Enum.find_value(fn
      {_visited, [], state} ->
        state.fastest
      {_, _, _} ->
        false
    end)
  end

  defp all_paths(state) do
    target_key = {state.target, :torch}
    state = Map.put(state, :fastest, :infinite)
    mouth = {0, 0}
    visited = Map.new([{{mouth, :torch}, 0}])
    new_regions = [{{mouth, :torch}, 0}]
    Stream.iterate({visited, new_regions, state},
      fn {visited, regions, state} ->
        {visited, new_regions, state} = expand_paths(visited, regions, state)
        case visited do
          %{^target_key => minutes} ->
            # Update the fastest path to the target. Reject all paths
            # that can't possibly be faster than this path.
            fastest = min(minutes, state.fastest)
            new_regions = reject_too_long(new_regions, fastest, state)
            #IO.inspect {minutes, length(new_regions)}
            state = %{state | fastest: minutes}
            {visited, new_regions, state}
          %{} ->
            # We have not found any path to the target yet.
            {visited, new_regions, state}
        end
      end)
  end

  defp reject_too_long(regions, fastest, %{target: target}) do
    Enum.reject(regions, fn {{pos, _tool}, so_far} ->
      # Reject this path if it can't possibly be faster than
      # the currently fastest path.
      fastest < so_far + manhattan_distance(pos, target)
    end)
  end

  defp manhattan_distance({x0, y0}, {x, y}) do
    abs(x0 - x) + abs(y0 - y)
  end

  defp expand_paths visited, regions, state do
    Enum.reduce(regions, {visited, [], state}, fn
      ({{region, tool}, minutes}, {visited, new_regions, state}) ->
	case next_path_positions(visited, region, tool, minutes, state) do
	  {[], state} ->
	    {visited, new_regions, state}
	  {new_path_regions, state} ->
            visited = Map.merge(visited, Map.new(new_path_regions))
            new_regions = new_path_regions ++ new_regions
            {visited, new_regions, state}
	end
    end)
  end

  defp next_path_positions visited, region, tool, minutes, state do
    adjacent_positions(region)
    |> Enum.reject(&solid_rock?/1)
    |> Enum.reduce({[], state}, fn new_region, {acc, state} ->
      {{tool, extra_minutes}, state} =
        fix_tool(region, new_region, tool, state)
      total_minutes = minutes + extra_minutes
      key = {new_region, tool}
      result =
        case visited do
          %{^key => prev_minutes} ->
            if total_minutes < prev_minutes do
              [{key, total_minutes} | acc]
            else
              acc
            end
          %{} ->
            [{key, total_minutes} | acc]
        end
      {result, state}
    end)
  end

  defp fix_tool(current_region, new_region, current_tool, state) do
    case state do
      %{:target => ^new_region} ->
        if current_tool == :torch do
          {{:torch, 1}, state}
        else
          {{:torch, 7 + 1}, state}
        end
      %{} ->
        {current_type, state} = symbolic_region_type(current_region, state)
        {new_type, state} = symbolic_region_type(new_region, state)
        acc = case is_tool_allowed(current_tool, new_type) do
                true ->
                  {current_tool, 1}
                false ->
                  Enum.reduce(other_tools(current_tool), nil,
                    fn new_tool, acc ->
                      case is_tool_allowed(new_tool, current_type) and
                      is_tool_allowed(new_tool, new_type) do
                        true -> {new_tool, 7 + 1}
                        false -> acc
                      end
                    end)
              end
        {acc, state}
    end
  end

  defp symbolic_region_type(region, state) do
    {level, state} = erosion_level(region, state)
    {elem({:rocky, :wet, :narrow}, rem(level, 3)), state}
  end

  defp is_tool_allowed(tool, region_type) when is_atom(tool) and is_atom(region_type) do
    tool in allowed_tools(region_type)
  end

  defp allowed_tools(:rocky), do: [:climbing_gear, :torch]
  defp allowed_tools(:wet), do: [:climbing_gear, :neither]
  defp allowed_tools(:narrow), do: [:torch, :neither]

  defp other_tools(tool) do
    Enum.reject([:climbing_gear, :torch, :neither], &(&1 == tool))
  end

  defp solid_rock?({x, y}), do: x < 0 or y < 0

  defp adjacent_positions({x, y}), do: [{x, y + 1}, {x, y - 1}, {x - 1, y}, {x + 1, y}]


  def initial_state(depth, target) do
    %{depth: depth, target: target, cache: %{}}
  end

  defp risk_levels(depth, {x, y} = target) do
    state = initial_state(depth, target)
    {types, _state} =
      Enum.reduce(0..x, {[], state}, fn x, acc ->
        Enum.reduce(0..y, acc, fn y, {types, state} ->
          pos = {x, y}
          {type, state} = type(pos, state)
          {[{pos, type} | types], state}
        end)
      end)
    types
  end

  defp type(pos, state) do
    {erosion_level, state} = erosion_level(pos, state)
    {rem(erosion_level, 3), state}
  end

  defp erosion_level(pos, state) do
    %{depth: depth, cache: cache} = state
    case cache do
      %{^pos => level} ->
        {level, state}
      %{} ->
        {geologic_level, state} = geologic_level(pos, state)
        level = rem(geologic_level + depth, 20183)
        cache = Map.put(cache, pos, level)
        state = %{state | cache: cache}
        {level, state}
    end
  end

  defp geologic_level({0, 0}, state), do: {0, state}
  defp geologic_level(pos, state) when pos == :erlang.map_get(:target, state) do
    {0, state}
  end
  defp geologic_level({x, 0}, state), do: {x * 16807, state}
  defp geologic_level({0, y}, state), do: {y * 48271, state}
  defp geologic_level({x, y}, state) do
    {level1, state} = erosion_level({x - 1, y}, state)
    {level2, state} = erosion_level({x, y - 1}, state)
    level = level1 * level2
    {level, state}
  end

  def print_board depth, target do
    state = initial_state depth, target
    extra = 5
    %{target: {max_x, max_y}} = state
     {str, _} = Enum.map_reduce(0..max_y+extra, state, fn y, acc ->
      {line, acc} =
        Enum.map_reduce(0..max_x+extra, acc, fn x, acc->
          pos = {x, y}
          {type, acc} = symbolic_region_type(pos, acc)
          char = case type do
                   :rocky when pos == {0, 0} -> ?M
                   :rocky when pos == target -> ?T
                   :rocky -> ?.
                   :wet -> ?=;
                   :narrow -> ?|
                 end
          {char, acc}
        end)
      {[line, "\n"], acc}
    end)
    IO.puts ""
    IO.puts str
  end

  defp parse([depth, target]) do
    "depth: " <> depth = depth
    depth = String.to_integer(depth)
    "target: " <> target = target
    {x, tail} = Integer.parse(target)
    "," <> tail = tail
    y = String.to_integer(tail)
    {depth, {x, y}}
  end
end
