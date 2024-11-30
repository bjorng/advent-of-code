defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part one, examples" do
    assert Day20.part1("^WNE$") == 3
    assert Day20.part1("^ENWWW(NEEE|SSE(EE|N))$") == 10
    assert Day20.part1("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$") == 18
    assert Day20.part1("^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$") == 23
    assert Day20.part1("^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$") == 31
  end

  test "part one, real data" do
    assert Day20.part1(input()) == 3872
  end

  test "part two, examples" do
    assert Day20.part2("^WNE$", 1) == 3
    assert Day20.part2("^WNE$", 2) == 2
    assert Day20.part2("^WNE$", 3) == 1
    assert Day20.part2("^WNE$", 4) == 0
    assert Day20.part2("^WNE$", 100) == 0
  end

  test "part two real data" do
    assert Day20.part2(input(), 1000) == 8600
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
