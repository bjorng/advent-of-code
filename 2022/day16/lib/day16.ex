defmodule Day16 do
  import Bitwise
  def part1(input) do
    graph = input
    |> parse
    |> rename
    open_valves = 0
    frontier = [{0, open_valves, 0}]
    seen = MapSet.new
    Stream.unfold({0, frontier, seen}, fn {minutes, frontier, seen} ->
      frontier = Enum.flat_map(frontier,
      fn state ->
        expand_frontier(state, minutes, graph)
      end)
      {frontier, seen} = Enum.flat_map_reduce(frontier, seen, fn state, seen ->
        {valves, _open_valves, pressure} = state
        key = {pressure, valves}
        case MapSet.member?(seen, key) do
          true ->
            {[], seen}
          false ->
            seen = MapSet.put(seen, key)
            {[state], seen}
        end
      end)
      {frontier, {minutes + 1, frontier, seen}}
    end)
    |> Stream.map(fn frontier ->
      frontier
      |> Enum.map(fn {_, _, pressure} -> pressure end)
      |> Enum.max(&>=/2, fn -> 0 end)
    end)
    |> Enum.take(30)
    |> Enum.max
  end

  def part2(input) do
    graph = input
    |> parse
    |> rename
    open_valves = 0
    frontier = [{0, open_valves, 0}]
    seen = MapSet.new
    Stream.unfold({4, frontier, seen}, fn {minutes, frontier, seen} ->
      {frontier, seen} = expand_frontier_part2(frontier, minutes, seen, graph)
      {frontier, {minutes + 1, frontier, seen}}
    end)
    |> Stream.map(fn frontier ->
      frontier
      |> Enum.map(fn {_, _, pressure} -> pressure end)
      |> Enum.max(&>=/2, fn -> 0 end)
    end)
    |> Enum.take(26)
    |> Enum.max
  end

  defp expand_frontier_part2(frontier, minutes, seen, graph) do
    Enum.flat_map_reduce(frontier, seen,
      fn {valves, open_valves, pressure}, seen ->
        valve1 = valves >>> 8
        valve2 = valves &&& 0xff
        states1 = expand_frontier({valve1, open_valves, 0}, minutes, graph)
        states2 = expand_frontier({valve2, open_valves, 0}, minutes, graph)
        combine_states(states1, states2, pressure)
        |> Enum.flat_map_reduce(seen, fn state, seen ->
          {valves, _open_valves, pressure} = state
          key = {pressure, valves}
          case MapSet.member?(seen, key) do
            true ->
              {[], seen}
            false ->
              seen = MapSet.put(seen, key)
              {[state], seen}
          end
        end)
      end)
  end

  defp expand_frontier(frontier, minutes, graph) do
    {valve, open_valves, pressure} = frontier
        {_, tunnels} = Map.get(graph, valve)
        states = Enum.map(tunnels, fn tunnel ->
          {tunnel, open_valves, pressure}
        end)
        case can_open_valve(valve, open_valves, graph) do
          nil ->
            states
          rate ->
            open_valves = open_valves ||| (1 <<< valve)
            pressure = pressure + (30 - minutes - 1) * rate
            state = {valve, open_valves, pressure}
            [state | states]
        end
  end

  defp combine_states(states1, states2, pressure) do
    Enum.flat_map(states1, fn {valve1, open_valves1, pressure1} ->
      Enum.map(states2, fn {valve2, open_valves2, pressure2} ->
        pressure = pressure + pressure1 +
        if valve1 !== valve2, do: pressure2, else: 0
        {min(valve1, valve2) <<< 8 ||| max(valve1, valve2),
         open_valves1 ||| open_valves2,
         pressure}
      end)
    end)
  end

  defp can_open_valve(valve, open_valves, graph) do
    case graph do
      %{^valve => {0, _}} ->
        nil
      %{^valve => {rate, _}} ->
        case (open_valves >>> valve) &&& 1 do
          1 -> nil
          0 -> rate
        end
    end
  end

  defp rename(input) do
    name_map = input
    |> Enum.sort
    |> Enum.with_index(fn {name, {_, _}}, index -> {name, index} end)
    |> Map.new

    Enum.map(input, fn {name, {rate, valves}} ->
      valves = Enum.map(valves, &Map.get(name_map, &1))
      {Map.get(name_map, name), {rate, valves}}
    end)
    |> Map.new
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      "Valve " <> rest = line
      {name, rest} = parse_valve(rest)
      " has flow rate=" <> rest = rest
      {rate, rest} = Integer.parse(rest)
      "; " <> rest = rest
      rest = case rest do
               "tunnels lead to valves " <> rest -> rest
               "tunnel leads to valve " <> rest -> rest
             end
      valves = parse_valves(rest)
      {name, {rate, valves}}
    end)
    |> Map.new
  end

  defp parse_valve(<<name::2-binary, rest::binary>>) do
    {String.to_atom(name), rest}
  end

  defp parse_valves(rest) do
    case parse_valve(rest) do
      {valve, ", " <> rest} ->
        [valve | parse_valves(rest)]
      {valve, ""} ->
        [valve]
    end
  end
end
