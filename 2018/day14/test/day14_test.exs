defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  test "part 1, examples" do
    assert Day14.part1("5") == 124515891
    assert Day14.part1("9") == 5158916779
    assert Day14.part1("18") == 9251071085
    assert Day14.part1("2018") == 5941429882
  end

  test "part 1, real input" do
    assert Day14.part1(input()) == 1464411010
  end

  test "part 2, examples" do
    assert Day14.part2("01245") == 5
    assert Day14.part2("51589") == 9
    assert Day14.part2("92510") == 18
    assert Day14.part2("59414") == 2018
    assert Day14.part2("074501") == 20_288_091
  end

  test "part 2, real input" do
    assert Day14.part2(input()) == 20288091
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
