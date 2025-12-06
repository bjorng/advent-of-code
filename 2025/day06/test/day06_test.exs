defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "part 1 with example" do
    assert Day06.part1(example()) == 4277556
  end

  test "part 1 with my input data" do
    assert Day06.part1(input()) == 4309240495780
  end

  test "part 2 with example" do
    assert Day06.part2(example()) == 3263827
  end

  test "part 2 with my input data" do
    assert Day06.part2(input()) == 9170286552289
  end

  defp example() do
    """
    123 328  51 64 
     45 64  387 23 
      6 98  215 314
    *   +   *   +  
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
