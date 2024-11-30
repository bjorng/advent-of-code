defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part 1 with example" do
    assert Day12.part1(example()) == 21
  end

  test "part 1 with my input data" do
    assert Day12.part1(input()) == 7674
  end

  test "part 2 with example" do
    assert Day12.part2(example()) == 525152
  end

  test "part 2 with my input data" do
    assert Day12.part2(input()) == 4443895258186
  end

  defp example() do
    """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
