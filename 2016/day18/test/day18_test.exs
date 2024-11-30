defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with example" do
    assert Day18.part1("..^^.", 3) == 6
    assert Day18.part1(".^^.^.^^^^", 10) == 38
  end

  test "part 1 with my input data" do
    assert Day18.part1(input()) == 2013
  end

  test "part 2 with my input data" do
    assert Day18.part2(input()) == 20006289
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
