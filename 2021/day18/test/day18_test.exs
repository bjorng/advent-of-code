defmodule Day18Test do
  use ExUnit.Case
  doctest Day18

  test "part 1 with example" do
    assert Day18.part1(example()) == 4140
  end

  test "part 1 with my input data" do
    assert Day18.part1(input()) == 4088
  end

  test "part 2 with example" do
    assert Day18.part2(example()) == 3993
  end

  test "part 2 with my input data" do
    assert Day18.part2(input()) == 4536
  end

  defp example() do
    """
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    [[[5,[2,8]],4],[5,[[9,9],0]]]
    [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    [[[[5,4],[7,7]],8],[[8,3],8]]
    [[9,3],[[9,9],[6,[4,9]]]]
    [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
