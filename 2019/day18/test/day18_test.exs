defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with examples" do
    assert Day18.part1(example1()) == 8
    assert Day18.part1(example2()) == 86
    assert Day18.part1(example3()) == 132
    assert Day18.part1(example5()) == 81
    assert Day18.part1(example4()) == 136
  end

  test "part 1 with my input" do
    assert Day18.part1(input()) == 4868
  end

  test "part 2 with examples" do
    assert Day18.part2(example6()) == 8
    assert Day18.part2(example7()) == 24
    assert Day18.part2(example8()) == 32
    assert Day18.part2(example9()) == 72
  end

  test "part 2 with my input" do
    assert Day18.part2(input()) == 1984
  end

  defp example1() do
    ["#########",
     "#b.A.@.a#",
     "#########"]
  end

  defp example2() do
    ["########################",
     "#f.D.E.e.C.b.A.@.a.B.c.#",
     "######################.#",
     "#d.....................#",
     "########################"]
  end


  defp example3() do
    ["########################",
     "#...............b.C.D.f#",
     "#.######################",
     "#.....@.a.B.c.d.A.e.F.g#",
     "########################"]
  end

  defp example4() do
    ["#################",
     "#i.G..c...e..H.p#",
     "########.########",
     "#j.A..b...f..D.o#",
     "########@########",
     "#k.E..a...g..B.n#",
     "########.########",
     "#l.F..d...h..C.m#",
     "#################"]
  end

  defp example5() do
    ["########################",
     "#@..............ac.GI.b#",
     "###d#e#f################",
     "###A#B#C################",
     "###g#h#i################",
     "########################"]
  end

  defp example6() do
    ["#######",
     "#a.#Cd#",
     "##@#@##",
     "#######",
     "##@#@##",
     "#cB#.b#",
     "#######"]
  end

  defp example7() do
    ["###############",
     "#d.ABC.#.....a#",
     "######@#@######",
     "###############",
     "######@#@######",
     "#b.....#.....c#",
     "###############"]
  end

  defp example8() do
    ["#############",
     "#DcBa.#.GhKl#",
     "#.###@#@#I###",
     "#e#d#####j#k#",
     "###C#@#@###J#",
     "#fEbA.#.FgHi#",
     "#############"]
  end

  defp example9() do
    ["#############",
     "#g#f.D#..h#l#",
     "#F###e#E###.#",
     "#dCba@#@BcIJ#",
     "#############",
     "#nK.L@#@G...#",
     "#M###N#H###.#",
     "#o#m..#i#jk.#",
     "#############"]
  end

  defp input() do
    File.read!("input.txt")
    |> String.trim
    |> String.split("\n")
  end
end
