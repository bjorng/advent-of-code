defmodule Day19Test do
  use ExUnit.Case
  doctest Day19

  test "part 1 with example" do
    assert Day19.part1(example()) == 19114
  end

  test "part 1 with my input data" do
    assert Day19.part1(input()) == 532551
  end

  test "part 2 with example" do
    assert Day19.part2(example()) == 167409079868000
  end

  test "part 2 with my input data" do
    assert Day19.part2(input()) == 134343280273968
  end

  defp example() do
    """
    px{a<2006:qkq,m>2090:A,rfg}
    pv{a>1716:R,A}
    lnx{m>1548:A,A}
    rfg{s<537:gd,x>2440:R,A}
    qs{s>3448:A,lnx}
    qkq{x<1416:A,crn}
    crn{x>2662:A,R}
    in{s<1351:px,qqz}
    qqz{s>2770:qs,m<1801:hdj,R}
    gd{a>3333:R,R}
    hdj{m>838:A,pv}

    {x=787,m=2655,a=1222,s=2876}
    {x=1679,m=44,a=2067,s=496}
    {x=2036,m=264,a=79,s=2244}
    {x=2461,m=1339,a=466,s=291}
    {x=2127,m=1623,a=2188,s=1013}
    """
    |> String.split("\n\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n\n", trim: true)
  end
end
