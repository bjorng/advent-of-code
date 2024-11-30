defmodule Day10 do
  def part1(input) do
    all = parse(input)
    |> Enum.sort

    built_in = List.last(all) + 3
    Enum.sort([0, built_in | all])
    |> count_differences(0, 0)
  end

  def part2(input) do
    Process.put(:mem, %{})
    parse(input)
    |> Enum.sort
    |> count_arrangments
  end

  defp count_arrangments(adapters) do
    {n, _memo} = count_arrangements(0, adapters, %{})
    n
  end

  def count_arrangements(current, adapters, memo) do
    case adapters do
      [adapter] when adapter - current <= 3 ->
        {1, memo}
      [_] ->
        {0, memo}
      [adapter | adapters] when adapter - current <= 3 ->
        key = [adapter | adapters]
        {n, memo} =
          case memo do
            %{^key => n} ->
              {n, memo}
            %{} ->
              {n, memo} = count_arrangements(adapter, adapters, memo)
              memo = Map.put(memo, key, n)
              {n, memo}
          end
        {n_rest, memo} = count_arrangements(current, adapters, memo)
        {n + n_rest, memo}
      [_ | _] ->
        {0, memo}
    end
  end

  defp count_differences([_], one, three), do: one * three
  defp count_differences([el1, el2 | tail], one, three) do
    case (el2 - el1) do
      1 -> count_differences([el2 | tail], one + 1, three)
      3 -> count_differences([el2 | tail], one, three + 1)
    end
  end

  def parse(input) do
    Enum.map(input, &String.to_integer/1)
  end
end
