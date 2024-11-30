defmodule Day12 do
  def part1(lines) do
    graph = parse(lines)
    length(reachable([0], graph, MapSet.new()))
  end

  def part2(lines) do
    graph = parse(lines)
    num_components([0], graph, MapSet.new(), 1)
  end

  defp reachable([id | ids], graph, seen) do
    case id in seen do
      :true ->
	reachable(ids, graph, seen)
      :false ->
	seen = MapSet.put(seen, id)
	ids = Map.get(graph, id) ++ ids
	[id | reachable(ids, graph, seen)]
    end
  end
  defp reachable([], _, _), do: []

  defp num_components([id | ids], graph, seen, n) do
    case id in seen do
      :true ->
	num_components(ids, graph, seen, n)
      :false ->
	seen = MapSet.put(seen, id)
        {connections, graph} = Map.pop(graph, id)
	ids = connections ++ ids
	num_components(ids, graph, seen, n)
    end
  end

  defp num_components([], graph, _, n) do
	case Map.keys(graph) do
	  [id | _] ->
	    num_components([id], graph, MapSet.new(), n + 1)
	  [] ->
	    n
	end
  end

  defp parse(lines) do
    lines
    |> Stream.map(&GraphParser.connections/1)
    |> Enum.map(fn {:ok, [result], "", _, _, _} ->
      result
    end)
    |> Map.new
  end
end

defmodule GraphParser do
  import NimbleParsec

  program_id = integer(min: 1)
  comma = ignore(string(", "))
  arrow = string(" <-> ")

  defcombinatorp(:connected_to,
      program_id
      |> repeat(comma |> parsec(:connected_to)))

  defparsec :connections, program_id
  |> ignore(arrow)
  |> parsec(:connected_to)
  |> eos()
  |> reduce({GraphParser.Helpers, :result, []})
end

defmodule GraphParser.Helpers do
  def result([id | connections]), do: {id, connections}
end
