defmodule Day06 do
  def part1(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(fn token ->
        case Integer.parse(token) do
          :error -> String.to_atom(token)
          {n, ""} -> n
        end
      end)
    end)
    |> transpose
    |> Enum.map(fn column ->
      operator = List.last(column)
      Enum.drop(column, -1)
      |> Enum.reduce(&(eval(operator, &1, &2)))
    end)
    |> Enum.sum
  end

  def part2(input) do
    operators = List.last(input)
    spaces = count_spaces(String.to_charlist(operators))
    operators = operators
    |> String.to_charlist
    |> Enum.filter(&(&1 !== ?\s))
    |> Enum.map(&List.to_atom([&1]))

    input
    |> Enum.drop(-1)
    |> Enum.map(fn line ->
      String.to_charlist(line)
      |> split_line(spaces)
    end)
    |> transpose
    |> Enum.zip(operators)
    |> Enum.map(fn {column, operator} ->
      column
      |> transpose
      |> Enum.map(fn column ->
        column
        |> Enum.filter(&(&1 !== ?\s))
        |> List.to_integer
      end)
      |> Enum.reduce(&(eval(operator, &1, &2)))
    end)
    |> Enum.sum
  end

  defp split_line([], []), do: []
  defp split_line(line, [n]) do
    {number, []} = Enum.split(line, n + 1)
    [number]
  end
  defp split_line(line, [n | ns]) do
    {number, rest} = Enum.split(line, n)
    [?\s | rest] = rest
    [number | split_line(rest, ns)]
  end

  defp count_spaces([]), do: []
  defp count_spaces([_op|rest]) do
    {spaces, rest} = Enum.split_while(rest, &(&1 === ?\s))
    [length(spaces) | count_spaces(rest)]
  end

  defp eval(operator, number1, number2) do
    apply(Kernel, operator, [number1, number2])
  end

  defp transpose(list) do
    Enum.zip_with(list, &Function.identity/1)
  end
end
