defmodule Day25Test do
  use ExUnit.Case
  doctest Day25

  test "part one, examples" do
    assert Day25.part1(example1()) == 2
    assert Day25.part1(example1a()) == 1
    assert Day25.part1(example2()) == 4
    assert Day25.part1(example3()) == 3
    assert Day25.part1(example4()) == 8
  end

  test "part one, real input" do
    assert Day25.part1(input()) == 370
  end

  defp example1 do
    """
    0,0,0,0
    3,0,0,0
    0,3,0,0
    0,0,3,0
    0,0,0,3
    0,0,0,6
    9,0,0,0
    12,0,0,0
    """
    |> String.split("\n", trim: true)
  end

  defp example1a do
    """
    0,0,0,0
    3,0,0,0
    0,3,0,0
    0,0,3,0
    0,0,0,3
    6,0,0,0
    0,0,0,6
    9,0,0,0
    12,0,0,0
    """
    |> String.split("\n", trim: true)
  end

  defp example2 do
    """
    -1,2,2,0
    0,0,2,-2
    0,0,0,-2
    -1,2,0,0
    -2,-2,-2,2
    3,0,2,-1
    -1,3,2,2
    -1,0,-1,0
    0,2,1,-2
    3,0,0,0
    """
    |> String.split("\n", trim: true)
  end

  defp example3 do
    """
    1,-1,0,1
    2,0,-1,0
    3,2,-1,0
    0,0,3,1
    0,0,-1,-1
    2,3,-2,0
    -2,2,0,0
    2,-2,0,-1
    1,-1,0,-1
    3,2,0,2
    """
    |> String.split("\n", trim: true)
  end

  defp example4 do
    """
    1,-1,-1,-2
    -2,-2,0,1
    0,2,1,3
    -2,3,-2,1
    0,2,3,-2
    -1,-1,1,-2
    0,-2,-1,0
    -2,2,3,-1
    1,2,2,0
    -1,-2,0,-2
    """
    |> String.split("\n", trim: true)
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
