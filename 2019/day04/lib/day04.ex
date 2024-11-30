defmodule Day04 do
  def part1(input) do
    parse(input)
    |> Stream.filter(&possible?/1)
    |> Enum.count
  end

  def part2(input) do
    parse(input)
    |> Stream.filter(&strict_possible?/1)
    |> Enum.count
  end

  def possible?(n) do
    digits = Integer.to_charlist(n)
    increasing?(digits) and double_digits?(digits)
  end

  def strict_possible?(n) do
    digits = Integer.to_charlist(n)
    increasing?(digits) and strict_double_digits?(digits)
  end

  defp increasing?([d1, d2 | digits]) when d1 <= d2 do
    increasing?([d2 | digits])
  end

  defp increasing?([_]), do: true
  defp increasing?(_), do: false

  defp double_digits?([d, d | _]), do: true
  defp double_digits?([_]), do: false
  defp double_digits?([_ | digits]), do: double_digits?(digits)

  defp strict_double_digits?([d, d, next | digits]) do
    case d === next do
      true ->
	digits = Enum.drop_while(digits, &(&1 === d))
	strict_double_digits?(digits)
      false ->
	true
    end
  end
  defp strict_double_digits?([d, d | _]), do: true
  defp strict_double_digits?([_ | digits]), do: strict_double_digits?(digits)
  defp strict_double_digits?([]), do: false

  defp parse(input) do
    {lower, "-" <> rest} = Integer.parse(input)
    upper = String.to_integer(rest)
    lower..upper
  end
end
