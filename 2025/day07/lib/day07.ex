defmodule Day07 do
  def part1(input) do
    {start, splitters} = parse_splitters(input)
    beams = [start]
    split_beams(beams, splitters, 0)
  end

  defp split_beams(_beams, [], num_splits), do: num_splits
  defp split_beams(beams, [splits | splitters], num_splits) do
    {beams, num_splits} = split_beams(beams, splits, [], num_splits)
    split_beams(beams, splitters, num_splits)
  end

  defp split_beams([], _splitters, new, num_splits) do
    {Enum.uniq(new), num_splits}
  end
  defp split_beams([column | beams], splits, new, num_splits) do
    case Enum.member?(splits, column) do
      true ->
        new = [column - 1, column + 1 | new]
        split_beams(beams, splits, new, num_splits + 1)
      false ->
        new = [column | new]
        split_beams(beams, splits, new, num_splits)
    end
  end

  def part2(input) do
    {start, splitters} = parse_splitters(input)
    {timelines, _} = count_timelines(start, splitters, %{})
    timelines
  end

  defp count_timelines(column, splitters, worlds) do
    key = {column, length(splitters)}
    case worlds do
      %{^key => timelines} ->
        {timelines, worlds}
      %{} ->
        {timelines, worlds} = count_timelines_split(column, splitters, worlds)
        {timelines, Map.put(worlds, key, timelines)}
    end
  end

  defp count_timelines_split(_column, [], worlds) do
    {1, worlds}
  end
  defp count_timelines_split(column, [splits | splitters], worlds) do
    case Enum.member?(splits, column) do
      true ->
        {timelines1, worlds} = count_timelines(column - 1, splitters, worlds)
        {timelines2, worlds} = count_timelines(column + 1, splitters, worlds)
        timelines = timelines1 + timelines2
        {timelines, worlds}
      false ->
        count_timelines(column, splitters, worlds)
    end
  end

  defp parse_splitters(input) do
    splitters = input
    |> Enum.map(fn line ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        case char do
          ?. -> []
          ?S -> [{:start, col}]
          ?^ -> [col]
        end
      end)
    end)
    [[{:start, start}] | splitters] = splitters
    {start, splitters}
  end
end
