defmodule Day12 do
  def part1(input) do
    parse(input)
    |> Enum.map(&count_arrangements/1)
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.map(fn {conditions, numbers} ->
      {List.flatten(Enum.intersperse(List.duplicate(conditions, 5), {:unknown, 1})),
       List.flatten(List.duplicate(numbers, 5))}
    end)
    |> Enum.map(&count_arrangements/1)
    |> Enum.sum
  end

  defp count_arrangements({conditions, numbers}) do
    result = %{}
    {n, _} = count_arrangements(conditions, numbers, result)
    n
  end

  defp count_arrangements(conditions, numbers, results) do
    case {conditions, numbers} do
      {[{:broken, num_broken1}, {:broken, num_broken2} | as], ns} ->
        memo_count_arrangements([{:broken, num_broken1 + num_broken2} | as], ns, results)
      {[{:working, _} | as], ns} ->
        memo_count_arrangements(as, ns, results)
      {[{:broken, num_broken}, {:unknown, num_unknown} | as], [num_broken | ns]} ->
        # The first unknown following a broken sequence is always working.
        memo_count_arrangements(add_unknown(as, num_unknown - 1), ns, results)
      {[{:broken, num_broken} | as], [num_broken | ns]} ->
        memo_count_arrangements(as, ns, results)
      {[{:broken, num_broken}, {:unknown, num_unknown} | as], [expected | ns]} ->
        missing = min(expected - num_broken, num_unknown)
        if missing >= 0 do
          num_unknown = num_unknown - missing
          as = [{:broken, num_broken + missing} | add_unknown(as, num_unknown)]
          memo_count_arrangements(as, [expected | ns], results)
        else
          {0, results}
        end
      {[{:unknown, num_unknown} | as], ns} ->
        as = add_unknown(as, num_unknown - 1)
        as1 = [{:working, 1} | as]
        as2 = [{:broken, 1} | as]
        {n1, results} = memo_count_arrangements(as1, ns, results)
        {n2, results} = memo_count_arrangements(as2, ns, results)
        {n1 + n2, results}
      {[], []} ->
        {1, results}
      {_, _} ->
        {0, results}
    end
  end

  defp memo_count_arrangements(as, ns, results) do
    key = {as, ns}
    case results do
      %{^key => n} ->
        {n, results}
      %{} ->
        {n, results} = count_arrangements(as, ns, results)
        {n, Map.put(results, key, n)}
    end
  end

  defp add_unknown([{:unknown, num_unknown} | as], n) do
    [{:unknown, num_unknown + n} | as]
  end
  defp add_unknown(as, n) when n > 0 do
    [{:unknown, n} | as]
  end
  defp add_unknown(as, _n), do: as

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [conditions | integers] = String.split(line, [" ", ","])
      conditions = conditions
      |> String.to_charlist
      |> Enum.chunk_by(&(&1))
      |> Enum.map(fn chars ->
        case chars do
          [?. | _] -> {:working, length(chars)}
          [?\# | _] -> {:broken, length(chars)}
          [?? | _] -> {:unknown, length(chars)}
        end
      end)
      {conditions, Enum.map(integers, &String.to_integer(&1))}
    end)
  end
end
