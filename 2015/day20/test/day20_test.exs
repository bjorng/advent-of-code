defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part 1 with examples" do
    assert Day20.presents_part1(1) == 10
    assert Day20.presents_part1(2) == 30
    assert Day20.presents_part1(3) == 40
    assert Day20.presents_part1(4) == 70
    assert Day20.presents_part1(5) == 60
    assert Day20.presents_part1(6) == 120
    assert Day20.presents_part1(7) == 80
    assert Day20.presents_part1(8) == 150
    assert Day20.presents_part1(9) == 130
    assert Day20.presents_part1(30) == 720
    assert Day20.presents_part1(31) == 320
    assert Day20.presents_part1(33) == 480
    assert Day20.presents_part1(35) == 480
    assert Day20.presents_part1(37) == 380
    assert Day20.presents_part1(39) == 560
    assert Day20.presents_part1(41) == 420
    assert Day20.presents_part1(49) == 570
    assert Day20.presents_part1(50) == 930
    assert Day20.presents_part1(51) == 720
    assert Day20.presents_part1(52) == 980
    assert Day20.presents_part1(53) == 540
    assert Day20.presents_part1(54) == 1200
    assert Day20.presents_part1(99) == 1560
    assert Day20.presents_part1(349) == 3500
    assert Day20.presents_part1(350) == 7440
    assert Day20.presents_part1(351) == 5600
    assert Day20.presents_part1(355) == 4320
    assert Day20.presents_part1(357) == 5760
    assert Day20.presents_part1(500) == 10920
    assert Day20.presents_part1(501) == 6720
    assert Day20.presents_part1(505) == 6120
    assert Day20.presents_part1(505) == 6120
    assert Day20.presents_part1(665280) == 29260800
  end

  test "part 1 with my input data" do
    assert Day20.part1(input()) == 665280
  end

  test "part 2 with examples" do
    assert Day20.presents_part2(1) == 11
    assert Day20.presents_part2(2) == 33
    assert Day20.presents_part2(3) == 44
    assert Day20.presents_part2(4) == 77
    assert Day20.presents_part2(5) == 66
    assert Day20.presents_part2(6) == 132
    assert Day20.presents_part2(7) == 88
    assert Day20.presents_part2(8) == 15 * 11
    assert Day20.presents_part2(9) == 13 * 11
    assert Day20.presents_part2(30) == 72 * 11
    assert Day20.presents_part2(31) == 32 * 11
    assert Day20.presents_part2(33) == 48 * 11
    assert Day20.presents_part2(35) == 48 * 11
    assert Day20.presents_part2(37) == 38 * 11
    assert Day20.presents_part2(39) == 56 * 11
    assert Day20.presents_part2(41) == 42 * 11
    assert Day20.presents_part2(49) == 57 * 11
    assert Day20.presents_part2(50) == 93 * 11
    assert Day20.presents_part2(51) == 72 * 11 - 11
    assert Day20.presents_part2(52) == 98 * 11 - 11
    assert Day20.presents_part2(53) == 54 * 11 - 11
    assert Day20.presents_part2(54) == 120 * 11 - 11
    assert Day20.presents_part2(99) == 156 * 11 - 11
    assert Day20.presents_part2(349) == 350 * 11 - 11
    assert Day20.presents_part2(350) == 744 * 11 - 5 * 11 - 2 * 11 - 11
    assert Day20.presents_part2(351) == 560 * 11 - 3 * 11 - 11
    assert Day20.presents_part2(355) == 432 * 11 - 5 * 11 - 11
    assert Day20.presents_part2(357) == 576 * 11 - 7 * 11 - 3 * 11 - 11
    assert Day20.presents_part2(500) == 1092 * 11 - 5 * 11 - 4 * 11 - 2 * 11 - 11
    assert Day20.presents_part2(501) == 672 * 11 - 3 * 11 - 11
    assert Day20.presents_part2(505) == 612 * 11 - 5 * 11 - 11
    assert Day20.presents_part2(705600) == 29002446
  end

  test "part 2 with my input data" do
    assert Day20.part2(input()) == 705600
  end

  defp input() do
    29000000
  end
end
