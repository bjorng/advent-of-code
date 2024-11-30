defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "part 1 with example" do
    assert Day06.part1(example1()) == 1000 * 1000
    assert Day06.part1(example2()) == 1000 * 1000 - 1000
    assert Day06.part1(example3()) == 1000 * 1000 - 4
  end

  test "part 1 with my input data" do
    assert Day06.part1(input()) == 569999
  end

  test "part 2 with example" do
    assert Day06.part2(["turn on 0,0 through 0,0"]) == 1
    assert Day06.part2(["toggle 0,0 through 999,999"]) == 2000000
  end

  test "part 2 with my input data" do
    assert Day06.part2(input()) == 17836115
  end

  defp example1() do
    """
    turn on 0,0 through 999,999
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    turn on 0,0 through 999,999
    toggle 0,0 through 999,0
    """
    |> String.split("\n", trim: true)
  end

  defp example3() do
    """
    turn on 0,0 through 999,999
    turn off 499,499 through 500,500
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
