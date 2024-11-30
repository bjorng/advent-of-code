defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "part 1 with example" do
    assert Day09.decompress("ADVENT") == "ADVENT"
    assert Day09.decompress("A(1x5)BC") == "ABBBBBC"
    assert Day09.decompress("(3x3)XYZ") == "XYZXYZXYZ"
    assert Day09.decompress("A(2x2)BCD(2x2)EFG") == "ABCBCDEFEFG"
    assert Day09.decompress("(6x1)(1x3)A") == "(1x3)A"
    assert Day09.decompress("X(8x2)(3x3)ABCY") == "X(3x3)ABC(3x3)ABCY"
  end

  test "part 1 with my input data" do
    assert Day09.part1(input()) == 107035
  end

  test "part 2 with examples" do
    assert Day09.part2("(3x3)XYZ") == 9
    assert Day09.part2("X(8x2)(3x3)ABCY") == 20
    assert Day09.part2("(27x12)(20x12)(13x14)(7x10)(1x12)A") == 241920
    assert Day09.part2("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN") == 445
  end

  test "part 2 with my input data" do
    assert Day09.part2(input()) == 11451628995
  end

  defp input() do
    File.read!("input.txt")
    |> String.replace(~r/\s+/, "", global: true)
  end
end
