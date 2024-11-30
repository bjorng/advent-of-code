defmodule Day19Test do
  use ExUnit.Case
  doctest Day19

  test "part 1 with example" do
    assert Day19.part1(example()) == 'ABCDEF'
  end

  test "part 1 with my input" do
    assert Day19.part1(input()) == 'GEPYAWTMLK'
  end

  test "part 2 with example" do
    assert Day19.part2(example()) == 38
  end

  test "part 2 with my input" do
    assert Day19.part2(input()) == 17628
  end

  def example() do
    """
        |          
        |  +--+    
        A  |  C    
    F---|----E|--+ 
        |  |  |  D 
        +B-+  +--+ 
    """
  end

  defp input do
    File.read!('input.txt')
  end
end
