defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "example" do
    assert Day17.count_tiles(example1()) == {28, 29, 57}
  end

  test "real data" do
    assert Day17.count_tiles(input()) == {5596, 24899, 30495}
  end

  defp example1() do
    """
    x=495, y=2..7
    y=7, x=495..501
    x=501, y=3..7
    x=498, y=2..4
    x=506, y=1..2
    x=498, y=10..13
    x=504, y=10..13
    y=13, x=498..504
    """
    |> String.trim
    |> String.split("\n")
  end


  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
