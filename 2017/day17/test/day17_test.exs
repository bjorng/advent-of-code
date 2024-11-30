defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "part 1 with examples" do
    assert Day17.part1(3) == 638
  end

  test "part 1 with my input" do
    assert Day17.part1(input()) == 417
  end

  test "part 2 with examples" do
    assert Day17.solve(3, 1) == 1
    assert Day17.solve(3, 2) == 2
    assert Day17.solve(3, 3) == 2
    assert Day17.solve(3, 4) == 2
    assert Day17.solve(3, 5) == 5
    assert Day17.solve(3, 9) == 9
    assert Day17.solve(3, 9) == 9
    assert Day17.solve(3, 10) == 9
    assert Day17.solve(3, 11) == 9
    assert Day17.solve(3, 12) == 12
    assert Day17.solve(input(), 2017) == 433
  end

  test "part 2 with my input" do
    assert Day17.part2(input()) == 34334221
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
    |> String.to_integer
  end
end
