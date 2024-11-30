defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "test part 1 with examples" do
    assert Day09.part1(example1()) == [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    assert Day09.part1("104,1125899906842624,99") == [1125899906842624]
#    assert Day09.part1("1102,34915192,34915192,7,4,7,99,0") == nil
  end

  test "test part 1 with my input" do
    assert Day09.part1(input()) == [2745604242]
  end

  test "test part 2 with my input" do
    assert Day09.part2(input()) == [51135]
  end

  defp example1() do
    "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
    |> hd
  end
end
