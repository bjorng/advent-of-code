defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "part 1 with example" do
    assert Day06.part1(example()) == "easter"
  end

  test "part 1 with my input data" do
    assert Day06.part1(input()) == "qrqlznrl"
  end

  test "part 2 with example" do
    assert Day06.part2(example()) == "advent"
  end

  test "part 2 with my input data" do
    assert Day06.part2(input()) == "kgzdfaon"
  end

  defp example() do
    """
    eedadn
    drvtee
    eandsr
    raavrd
    atevrs
    tsrnev
    sdttsa
    rasrtv
    nssdts
    ntnada
    svetve
    tesnvt
    vntsnd
    vrdear
    dvrsen
    enarar
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
