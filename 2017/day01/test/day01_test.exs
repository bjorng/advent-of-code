defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "test part 1 with examples" do
    assert Day01.part1("1122") == 3
    assert Day01.part1("1111") == 4
    assert Day01.part1("1234") == 0
    assert Day01.part1("91212129") == 9
  end

  test "test part 1 with my input data" do
    assert Day01.part1(input()) == 1228
  end

  test "test part 2 with examples" do
    assert Day01.part2("1212") == 6
    assert Day01.part2("1221") == 0
    assert Day01.part2("123425") == 4
    assert Day01.part2("123123") == 12
    assert Day01.part2("12131415") == 4
  end

  test "test part 2 with my input data" do
    assert Day01.part2(input()) == 1238
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
