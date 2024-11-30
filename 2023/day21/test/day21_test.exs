defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with example" do
    assert Day21.part1(example(), 6) == 16
  end

  test "part 1 with my input data" do
    assert Day21.part1(input()) == 3600
  end

  test "part 2 with example" do
#    assert Day21.part2(example(), 10) == 50
#    assert Day21.part2(example(), 50) == 1594
#    assert Day21.part2(example(), 100) == 6536
#    assert Day21.part2(example(), 500) == 167004
#    assert Day21.part2(example(), 1000) == 668697
#    assert Day21.part2(example(), 5000) == 16733044
  end

  test "part 2 with my input data" do
    assert Day21.part2(input(), 2 * 131 + 65) == 91890
    assert Day21.part2(input(), 4 * 131 + 65) == 297300
    assert Day21.part2(input(), 6 * 131 + 65) == 619950
    assert Day21.part2(input(), 8 * 131 + 65) == 1059840
    assert Day21.part2(input(), 10 * 131 + 65) == 1616970

    assert Day21.part2(input()) == 599763113936220
  end

  defp example() do
    """
    ...........
    .....###.#.
    .###.##..#.
    ..#.#...#..
    ....#.#....
    .##..S####.
    .##..#...#.
    .......##..
    .##.#.####.
    .##..##.##.
    ...........
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
