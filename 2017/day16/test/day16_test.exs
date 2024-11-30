defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  test "test part 1 with example" do
    assert Day16.part1("s1,x3/4,pe/b", 5) == "baedc"
  end

  test "test part 1 with input" do
    assert Day16.part1(input(), 16) == "cgpfhdnambekjiol"
  end

  test "test part 2 with example" do
    assert Day16.part2("s1,x3/4,pe/b", 5) == "abcde"
  end

  test "test part 2 with input" do
    assert Day16.part2(input(), 16) == "gjmiofcnaehpdlbk"
  end

  defp input() do
    [line] = File.stream!("input.txt")
    |> Enum.map(&String.trim/1)
    line
  end

end
