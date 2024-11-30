defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  test "part 1 with example" do
    assert Day10.part1(example()) == 26397
  end

  test "part 1 with my input data" do
    assert Day10.part1(input()) == 193275
  end

  test "part 2 with example" do
    assert Day10.part2(example()) == 288957
  end

  test "part 2 with my input data" do
    assert Day10.part2(input()) == 2429644557
  end

  defp example() do
    """
    [({(<(())[]>[[{[]{<()<>>
    [(()[<>])]({[<{<<[]>>(
    {([(<{}[<>[]}>{[]{[(<()>
    (((({<>}<{<{<>}{[]{[]{}
    [[<[([]))<([[{}[[()]]]
    [{[{({}]{}}([{[{{{}}([]
    {<[[]]>}<{[{[{[]{()[[[]
    [<(<(<(<{}))><([]([]()
    <{([([[(<>()){}]>(<<{{
    <{([{{}}[<[[[<>{}]]]>[]]
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
