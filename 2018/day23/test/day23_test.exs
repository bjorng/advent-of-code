defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part one, examples" do
    assert Day23.part1(example1()) == 7
  end

  test "part one, real input" do
    assert Day23.part1(input()) == 906
  end

  test "part two, examples" do
    assert Day23.part2(example1()) == {1, {1, 0, 0}}
    assert Day23.part2(example2()) == {36, {12, 12, 12}}
  end

  test "part two, real data" do
    # Too low: {121408426, {44959166, 21635823, 54813437}}
    # Too low: {121493969, {43234592, 21678589, 56580788}}
    # Too low: {121493969, {50995977, 21629285, 48868707}}
    assert Day23.part2(input()) ==
    {121493971, {50995978, 21678597, 48819396}}
  end

  test "part two, sanity check" do
    assert Day23.num_overlapping(example1(), {0, 0, 0}) == 2

    assert Day23.num_overlapping(input(),
      {50995978, 21678597, 48819396}) == 985

    assert Day23.num_overlapping(input(),
      {50995977, 21629285, 48868707}) == 953

    assert Day23.num_overlapping(input(),
      {43234592, 21678589, 56580788}) == 885

    assert Day23.num_overlapping(input(),
      {44959166, 21635823, 54813437}) == 873

    assert Day23.num_overlapping(input(),
      {42880486, 19804869, 55061160}) == 867

    assert Day23.num_overlapping(input(),
      {49353768, 21678590, 50461611}) == 937

    assert Day23.num_overlapping(input(),
      {151380879, -112300090, -137926293}) == 0

    assert Day23.num_overlapping(input(),
      {-151380879, 15028385, 61628534}) == 3

    assert Day23.num_overlapping(input(),
      {-151380, 1502838, 28534}) == 132
  end

  defp example1 do
    """
    pos=<0,0,0>, r=4
    pos=<1,0,0>, r=1
    pos=<4,0,0>, r=3
    pos=<0,2,0>, r=1
    pos=<0,5,0>, r=3
    pos=<0,0,3>, r=1
    pos=<1,1,1>, r=1
    pos=<1,1,2>, r=1
    pos=<1,3,1>, r=1
    """
    |> String.split("\n", trim: true)
  end

  defp example2 do
    """
    pos=<10,12,12>, r=2
    pos=<12,14,12>, r=2
    pos=<16,12,12>, r=4
    pos=<14,14,14>, r=6
    pos=<50,50,50>, r=200
    pos=<10,10,10>, r=5
    """
    |> String.split("\n", trim: true)
  end

  defp input do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
