defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part 1 with example" do
    assert Day12.part1(["[1,2,3]"]) == 6
    assert Day12.part1(["{\"a\":2,\"b\":4}"]) == 6
    assert Day12.part1(["[[[3]]]"]) == 3
    assert Day12.part1(["{\"a\":{\"b\":4},\"c\":-1}"]) == 3
    assert Day12.part1(["{\"a\":[-1,1]}"]) == 0
    assert Day12.part1(["[-1,{\"a\":1}]"]) == 0
    assert Day12.part1(["[]"]) == 0
    assert Day12.part1(["{}"]) == 0
  end

  test "part 1 with my input data" do
    assert Day12.part1(input()) == 111754
  end

  test "part 2 with example" do
    assert Day12.part2(["[1,2,3]"]) == 6
    assert Day12.part2(["{\"a\":2,\"b\":4}"]) == 6
    assert Day12.part2(["[[[3]]]"]) == 3
    assert Day12.part2(["{\"a\":{\"b\":4},\"c\":-1}"]) == 3
    assert Day12.part2(["{\"a\":[-1,1]}"]) == 0
    assert Day12.part2(["[-1,{\"a\":1}]"]) == 0
    assert Day12.part2(["[]"]) == 0
    assert Day12.part2(["{}"]) == 0
    assert Day12.part2(["[1,\"red\",5]"]) == 6
    assert Day12.part2(["[1,{\"c\":\"red\",\"b\":2},3]"]) == 4
    assert Day12.part2(["{\"d\":\"red\",\"e\":[1,2,3,4],\"f\":5}"]) == 0
  end

  test "part 2 with my input data" do
    assert Day12.part2(input()) == 65402
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
