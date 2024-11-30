defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  test "part 1 with example" do
    assert Day11.part1(example()) == 10605
  end

  test "part 1 with my input data" do
    assert Day11.part1(input()) == 55458
  end

  test "part 2 with example" do
    assert Day11.part2(example()) == 2713310158
  end

  test "part 2 with my input data" do
    assert Day11.part2(input()) == 14508081294
  end

  defp example() do
    """
    Monkey 0:
      Starting items: 79, 98
      Operation: new = old * 19
      Test: divisible by 23
        If true: throw to monkey 2
        If false: throw to monkey 3

    Monkey 1:
      Starting items: 54, 65, 75, 74
      Operation: new = old + 6
      Test: divisible by 19
        If true: throw to monkey 2
        If false: throw to monkey 0

    Monkey 2:
      Starting items: 79, 60, 97
      Operation: new = old * old
      Test: divisible by 13
        If true: throw to monkey 1
        If false: throw to monkey 3

    Monkey 3:
      Starting items: 74
      Operation: new = old + 3
      Test: divisible by 17
        If true: throw to monkey 0
        If false: throw to monkey 1
    """
  end

  defp input() do
    File.read!("input.txt")
  end
end
