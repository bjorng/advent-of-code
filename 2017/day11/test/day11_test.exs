defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "test part 1 with examples" do
    assert Day11.part1("ne,ne,ne") == 3
    assert Day11.part1("ne,ne,sw,sw") == 0
    assert Day11.part1("ne,ne,s,s") == 2
    assert Day11.part1("se,sw,se,sw,sw") == 3
  end

  test "test part 1 with my input data" do
    assert Day11.part1(input()) == 818
  end

  test "test part 2 with my input data" do
    assert Day11.part2(input()) == 1596
  end

  defp input() do
    File.read!("input.txt")
    |> String.trim
  end

end
