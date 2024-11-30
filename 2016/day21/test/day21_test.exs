defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with example" do
    assert Day21.part1(even_simpler_example(), "abcdefghi") == "edcbafghi"
    assert Day21.part1(simpler_example(), "abcdefghi") == "fbdecghia"
    assert Day21.part1(example(), "abcde") == "decab"
    assert Day21.part1(example(), "abcdefgh") == "fbdecgha"
  end

  test "part 1 with my input data" do
    assert Day21.part1(input(), "abcdefgh") == "bfheacgd"
  end

  test "part 2 with example" do
    assert Day21.part2(even_simpler_example(), "edcbafghi") == "abcdefghi"
    assert Day21.part2(simpler_example(), "fbdecghia") == "abcdefghi"
    assert Day21.part2(example(), "decab") == "abcde"
    assert Day21.part2(example(), "fbdecgha") == "abcdefgh"
  end

  test "part 2 with my input data" do
    assert Day21.part2(input(), "fbgdceah") == "gcehdbfa"
  end

  defp example() do
    """
    swap position 4 with position 0
    swap letter d with letter b
    reverse positions 0 through 4
    rotate left 1 step
    move position 1 to position 4
    move position 3 to position 0
    rotate based on position of letter b
    rotate based on position of letter d
    """
    |> String.split("\n", trim: true)
  end

  defp simpler_example() do
    """
    swap position 4 with position 0
    swap letter d with letter b
    reverse positions 0 through 4
    rotate left 1 step
    move position 1 to position 4
    move position 3 to position 0
    """
    |> String.split("\n", trim: true)
  end

  defp even_simpler_example() do
    """
    swap position 4 with position 0
    swap letter d with letter b
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
