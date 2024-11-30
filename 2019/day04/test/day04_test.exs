defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "test part 1 with examples" do
    assert Day04.possible?(111111) == true
    assert Day04.possible?(223450) == false
    assert Day04.possible?(123789) == false
  end

  test "test part 1 with my input" do
    assert Day04.part1(input()) == 1079
  end

  test "test part 2 with examples" do
    assert Day04.strict_possible?(112233) == true
    assert Day04.strict_possible?(123444) == false
    assert Day04.strict_possible?(111122) == true
  end

  test "test part 2 with my input" do
    assert Day04.part2(input()) == 699
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
