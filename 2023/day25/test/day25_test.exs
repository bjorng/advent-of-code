defmodule Day25Test do
  use ExUnit.Case
  doctest Day25

  test "part 1 with example" do
    assert Day25.part1(example()) == 54
  end

  test "part 1 with my input data" do
    # 2476 left
    # gpj/tmb, hrv/bgf, rhh/mtc
    # 4667.0 seconds
    assert Day25.part1(input()) == 558376
  end

  defp example() do
    """
    jqt: rhn xhk nvd
    rsh: frs pzl lsr
    xhk: hfx
    cmg: qnr nvd lhk bvb
    rhn: xhk bvb hfx
    bvb: xhk hfx
    pzl: lsr hfx nvd
    qnr: nvd
    ntq: jqt hfx bvb xhk
    nvd: lhk
    lsr: lhk
    rzs: qnr cmg lsr rsh
    frs: qnr lhk lsr
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
