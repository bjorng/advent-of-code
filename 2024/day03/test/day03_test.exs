defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "part 1 with example" do
    assert Day03.part1(example()) == 161
  end

  test "part 1 with my input data" do
    assert Day03.part1(input()) == 170778545
  end

  test "part 2 with example" do
    assert Day03.part2(example2()) == 48
  end

  test "part 2 with my input data" do
    assert Day03.part2(input()) == 82868252
  end

  defp example() do
    """
    xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
    """
  end

  defp example2() do
    """
    xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    """
  end

  defp input() do
    File.read!("input.txt")
  end
end
