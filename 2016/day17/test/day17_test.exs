defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "part 1 with example" do
    assert Day17.part1("ihgpwlah") == "DDRRRD"
    assert Day17.part1("kglvqrro") == "DDUDRLRRUDRD"
    assert Day17.part1("ulqzkmiv") == "DRURDRUDDLLDLUURRDULRLDUUDDDRR"
  end

  test "part 1 with my input data" do
    assert Day17.part1(input()) == "DUDRDLRRRD"
  end

  test "part 2 with example" do
    assert Day17.part2("ihgpwlah") == 370
    assert Day17.part2("kglvqrro") == 492
    assert Day17.part2("ulqzkmiv") == 830
  end

  test "part 2 with my input data" do
    assert Day17.part2(input()) == 502
  end

  defp input(), do: "edjrjqaa"
end
