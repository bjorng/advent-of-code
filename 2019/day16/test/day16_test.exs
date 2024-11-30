defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "part 1 with examples" do
    assert Day16.part1("12345678") == "23845678"
    assert Day16.part1("80871224585914546619083218645595") == "24176176"
    assert Day16.part1("19617804207202209144916044189917") == "73745418"
    assert Day16.part1("69317163492948606335995924319873") == "52432133"
  end

  test "part 1 with my input" do
    assert Day16.part1(input()) == "96136976"
  end

  test "part 2 with examples" do
    assert Day16.part2("03036732577212944063491565474664") == "84462026"
    assert Day16.part2("02935109699940807407585447034323") == "78725270"
    assert Day16.part2("03081770884921959731165446850517") == "53553731"
  end

  test "part 2 with my input" do
    assert Day16.part2(input()) == "85600369"
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
