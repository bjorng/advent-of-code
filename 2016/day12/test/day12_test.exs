defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part 1 with example" do
    assert Day12.part1(example()) == 42
  end

  test "part 1 with my input data" do
    assert Day12.part1(input()) == 318117
  end

  test "part 2 with my input data" do
    assert Day12.part2(input()) == 9227771
  end

  defp example() do
    """
    cpy 41 a
    inc a
    inc a
    dec a
    jnz a 2
    dec a
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
