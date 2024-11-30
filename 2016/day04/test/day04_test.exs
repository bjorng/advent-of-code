defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "part 1 with example" do
    assert Day04.part1(example()) == 1514
  end

  test "part 1 with my input data" do
    assert Day04.part1(input()) == 361724
  end

  test "part 2 with example" do
    assert Day04.test_shift_cipher("qzmt-zixmtkozy-ivhz-343[abcde]") == "very encrypted name"
  end

  test "part 2 with my input data" do
    assert Day04.part2(input()) == 482
  end

  defp example() do
    """
    aaaaa-bbb-z-y-x-123[abxyz]
    a-b-c-d-e-f-g-h-987[abcde]
    not-a-real-room-404[oarel]
    totally-real-room-200[decoy]
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
