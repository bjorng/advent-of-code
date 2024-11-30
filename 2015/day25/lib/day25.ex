defmodule Day25 do
  def part1(input) do
    target = parse(input)

    Stream.unfold({{0, 0}, 20151125}, &next_code/1)
    |> Stream.drop_while(fn {position, _} -> position !== target end)
    |> Enum.take(1)
    |> hd
    |> elem(1)
  end

  defp next_code({{row, col}, code}) do
    next_code = rem(code * 252533, 33554393)
    next_position = if row <= 1 do
      {col + 1, 1}
    else
      {row - 1, col + 1}
    end
    {{next_position, code}, {next_position, next_code}}
  end

  defp parse(input) do
    [line | _] = input
    Regex.run(~r/(\d+)\D*(\d+)/, line, [capture: :all_but_first])
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end
