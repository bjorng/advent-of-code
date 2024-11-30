defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "part 1 with example" do
    assert Day03.part1(["5 10 25"]) == 0
    end

  test "part 1 with my input data" do
    assert Day03.part1(input()) == 1032
  end

  test "part 2 with example 2" do
    assert Day03.part2(example()) == 6
  end

  test "part 2 with my input data" do
    assert Day03.part2(input()) == 1838
  end

  defp example() do
    """
    101 301 501
    102 302 502
    103 303 503
    201 401 601
    202 402 602
    203 403 603
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
