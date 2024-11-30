defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "part 1 with example" do
    assert Day12.part1(example1()) == 10
    assert Day12.part1(example2()) == 19
    assert Day12.part1(example3()) == 226
  end

  test "part 1 with my input data" do
    assert Day12.part1(input()) == 3708
  end

  test "part 2 with example" do
    assert Day12.part2(example1()) == 36
    assert Day12.part2(example2()) == 103
    assert Day12.part2(example3()) == 3509
  end

  test "part 2 with my input data" do
    assert Day12.part2(input()) == 93858
  end

  defp example1() do
    """
    start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end
    """
    |> String.split("\n", trim: true)
  end

  defp example2() do
    """
    dc-end
    HN-start
    start-kj
    dc-start
    dc-HN
    LN-dc
    HN-end
    kj-sa
    kj-HN
    kj-dc
    """
    |> String.split("\n", trim: true)
  end

  defp example3() do
    """
    fs-end
    he-DX
    fs-he
    start-DX
    pj-DX
    end-zg
    zg-sl
    zg-pj
    pj-he
    RW-he
    fs-DX
    pj-RW
    zg-RW
    start-pj
    he-WI
    zg-he
    pj-fs
    start-RW
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
