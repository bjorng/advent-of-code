defmodule Day25Test do
  use ExUnit.Case
  doctest Day25

  test "part 1 with example" do
    assert Day25.part1(example()) == 14897079
  end

  test "part 1 with my input data" do
    assert Day25.part1(input()) == 10548634
  end


  defp example() do
    """
    5764801
    17807724
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
