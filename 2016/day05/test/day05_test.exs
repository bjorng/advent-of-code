defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "part 1 with example" do
    assert Day05.part1(example()) == "18f47a30"
  end

  test "part 1 with my input data" do
    assert Day05.part1(input()) == "801b56a7"
  end

  test "part 2 with example" do
    assert Day05.part2(example()) == "05ace8e3"
  end

  test "part 2 with my input data" do
    assert Day05.part2(input()) == "424a0197"
  end

  defp example(), do: "abc"

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
