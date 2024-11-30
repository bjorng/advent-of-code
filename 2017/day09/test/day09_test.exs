defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "test part 1 with examples" do
    assert Day09.part1("{}") == 1
    assert Day09.part1("{{{}}}") == 6
    assert Day09.part1("{{},{}}") == 5
    assert Day09.part1("{{{},{},{{}}}}") == 16
    assert Day09.part1("{<a>,<a>,<a>,<a>}") == 1
    assert Day09.part1("{{<ab>},{<ab>},{<ab>},{<ab>}}") == 9
    assert Day09.part1("{{<!!>},{<!!>},{<!!>},{<!!>}}") == 9
    assert Day09.part1("{{<a!>},{<a!>},{<a!>},{<ab>}}") == 3
  end

  test "test part 1 with my input data" do
    assert Day09.part1(input()) == 11846
  end

  test "test part 2 with examples" do
    assert Day09.part2("<>") == 0
    assert Day09.part2("<random characters>") == 17
    assert Day09.part2("<<<<>") == 3
    assert Day09.part2("<{!>}>") == 2
    assert Day09.part2("<!!>") == 0
    assert Day09.part2("<!!!>>") == 0
    assert Day09.part2("<{o\"i!a,<{i<a>") == 10
    end

  test "test part 2 with my input data" do
    assert Day09.part2(input()) == 6285
  end

  defp input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.at(0)
  end
end
