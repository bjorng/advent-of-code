defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "part 1 with example" do
    assert Day06.part1(example1()) == 7
    assert Day06.part1(example2()) == 5
    assert Day06.part1(example3()) == 6
    assert Day06.part1(example4()) == 10
    assert Day06.part1(example5()) == 11
  end

  test "part 1 with my input data" do
    assert Day06.part1(input()) == 1987
  end

  test "part 2 with example" do
    assert Day06.part2(example1()) == 19
    assert Day06.part2(example2()) == 23
    assert Day06.part2(example3()) == 23
    assert Day06.part2(example4()) == 29
    assert Day06.part2(example5()) == 26
  end

  test "part 2 with my input data" do
    assert Day06.part2(input()) == 3059
  end

  defp example1(), do: "mjqjpqmgbljsphdztnvjfqwrcgsmlb"
  defp example2(), do: "bvwbjplbgvbhsrlpgdmjqwftvncz"
  defp example3(), do: "nppdvjthqldpwncqszvftbrmjlhg"
  defp example4(), do: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"
  defp example5(), do: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> hd
  end
end
