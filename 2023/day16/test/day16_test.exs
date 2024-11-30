defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "part 1 with example" do
    assert Day16.part1(example()) == 46
  end

  test "part 1 with my input data" do
    assert Day16.part1(input()) == 7632
  end

  test "part 2 with example" do
    assert Day16.part2(example()) == 51
  end

  test "part 2 with my input data" do
    assert Day16.part2(input()) == 8023
  end

  defp example() do
    ~S"""
    .|...\....
    |.-.\.....
    .....|-...
    ........|.
    ..........
    .........\
    ..../.\\..
    .-.-/..|..
    .|....-|.\
    ..//.|....
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
