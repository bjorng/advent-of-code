defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part one example" do
    assert Day12.part1(data()) == 325
  end

  test "part one real data" do
    assert Day12.part1(input()) == 3738
  end

  test "part two example" do
    assert Day12.part2(data()) == 999999999374
  end

  test "part two real data" do
    assert Day12.part2(input()) == 3900000002467
  end

  defp data() do
  """
  initial state: #..#.#..##......###...###

  ...## => #
  ..#.. => #
  .#... => #
  .#.#. => #
  .#.## => #
  .##.. => #
  .#### => #
  #.#.# => #
  #.### => #
  ##.#. => #
  ##.## => #
  ###.. => #
  ###.# => #
  ####. => #
  """
  |> String.trim
  |> String.split("\n")
  end

  defp input() do
    File.read!("input.txt")
    |> String.trim
    |> String.split("\n")
  end
end
