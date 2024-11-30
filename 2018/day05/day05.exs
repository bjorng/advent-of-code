#
# To run tests:
#
#    elixir day05.exs
#
# To run part 1 and 2:
#
#    > iex day05.exs
#    [iex]> Day05.part1
#    [iex]> Day05.part2
#

defmodule Day05 do
  def part1 do
    input()
    |> Enum.map(&alchemical_reduction/1)
    |> hd
  end

  def part2 do
    input()
    |> Enum.map(&shortest_reduction/1)
    |> hd
  end

  def input do
    "input.txt"
    |> File.stream!([], :line)
    |> Enum.map(fn line -> String.trim(line) end)
  end

  def shortest_reduction string do
    chars = String.to_charlist string
    ?A..?Z
    |> Enum.map(fn letter ->
      modified_chars = Enum.reject(chars, &(&1 == letter or &1 == letter+32))
      red modified_chars
    end)
    |> Enum.min
  end

  def alchemical_reduction string do
    red String.to_charlist(string)
  end

  defp red string do
    reduced = red string, []
    length reduced
  end

  defp red [u1, u2 | t], acc do
    case reacts u1, u2 do
      true ->
	case acc do
	  [a1 | acc] ->
	    red [a1 | t], acc
	  [] ->
	    red t, acc
	end
      false ->
	red [u2 | t], [u1 | acc]
    end
  end

  defp red [u], acc do
    Enum.reverse(acc, [u])
  end

  defp red [], acc do
    Enum.reverse(acc)
  end

  defp reacts u, u do
    false
  end

  defp reacts u1, u2 do
    (u1 < u2 and u1+32 == u2) or u1-32 == u2
  end
end

ExUnit.start()

defmodule Day05Test do
  use ExUnit.Case

  import Day05

  test "part one" do
    assert alchemical_reduction(data()) == 10
  end

  test "part two" do
    assert shortest_reduction(data()) == 4
  end

  defp data do
    "dabAcCaCBAcCcaDA"
  end
end
