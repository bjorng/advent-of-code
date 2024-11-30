defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "part 1 with example" do
    assert Day21.part1(example()) == 5
  end

  test "part 1 with my input data" do
    assert Day21.part1(input()) == 2380
  end

  test "part 2 with example" do
    assert Day21.part2(example()) == "mxmxvkd,sqjhc,fvjkl"
  end

  test "part 2 with my input data" do
    assert Day21.part2(input()) == "ktpbgdn,pnpfjb,ndfb,rdhljms,xzfj,bfgcms,fkcmf,hdqkqhh"
  end

  defp example() do
    """
    mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
    trh fvjkl sbzzf mxmxvkd (contains dairy)
    sqjhc fvjkl (contains soy)
    sqjhc mxmxvkd sbzzf (contains fish)
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end

