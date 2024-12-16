defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "part 1 with example" do
    assert Day23.part1(example()) == 7
  end

  test "part 1 with my input data" do
    assert Day23.part1(input()) == 926
  end

  test "part 2 with example" do
    assert Day23.part2(example()) == "co,de,ka,ta"
  end

  test "part 2 with my input data" do
    assert Day23.part2(input()) == "az,ed,hz,it,ld,nh,pc,td,ty,ux,wc,yg,zz"
  end

  defp example() do
    """
    kh-tc
    qp-kh
    de-cg
    ka-co
    yn-aq
    qp-ub
    cg-tb
    vc-aq
    tb-ka
    wh-tc
    yn-cg
    kh-ub
    ta-co
    de-co
    tc-td
    tb-wq
    wh-td
    ta-ka
    td-qp
    aq-cg
    wq-ub
    ub-vc
    de-ta
    wq-aq
    wq-vc
    wh-yn
    ka-de
    kh-ta
    co-tc
    wh-qp
    tb-vc
    td-yn
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
