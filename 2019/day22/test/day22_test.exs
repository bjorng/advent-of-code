defmodule Day22Test do
  use ExUnit.Case
  doctest Day22
  doctest Day22Alt

  test "part 1 with my examples" do
    assert Day22.part1(example1(), 10) == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
    assert Day22.part1(example2(), 10) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
    assert Day22.part1(example3(), 10) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
  end

  test "part 1 with my input" do
    assert Day22.part1(input()) == 7096
  end

  defp test_modinv(a, b) do
    assert Day22.mod_inv(a, b) === Day22Alt.mod_inv(a, b)
  end

  test "modular multiplicative inverse" do
    test_modinv(899, 10007)
    test_modinv(5933, 10007)
    test_modinv(15000, 10007)
  end

  test "part 2 with my examples" do
    assert Day22.brute_solve(input(), 14449, 1) == 6814
    assert Day22.brute_solve(input(), 19477, 1) == 7949
    assert Day22.brute_solve(input(), 10_007, 1) == 3115
    assert Day22.brute_solve(input(), 10_007, 2) == 3470
    assert Day22.lazy_solve(input(), 14449, 1) == 6814
    assert Day22.lazy_solve(input(), 19477, 1) == 7949
    assert Day22.lazy_solve(input(), 10_007, 1) == 3115
    assert Day22.lazy_solve(input(), 10_007, 2) == 3470
    assert Day22.lazy_solve(input(), 10_007, 5) == 8727
    assert Day22.lazy_solve(input(), 10_007, 20) == 7007
    assert Day22.lazy_solve(input(), 10_007, 50) == 8763
    assert Day22.lazy_solve(input(), 10_007, 100) == 3801
    assert Day22.lazy_solve(input(), 104639, 11) == 79828
    assert Day22.lazy_solve(input(), 119_315_717_514_047, 1) == 101498718840506
    assert Day22.lazy_solve(input(), 119_315_717_514_047, 55) == 84400609078784
    assert Day22.lazy_solve(input(), 119_315_717_514_047, 7777) == 59571543365254
#    assert Day22.brute_solve(input(), 10_007, 5) == 8727
#    assert Day22.brute_solve(input(), 10_007, 20) == 7007
#    assert Day22.brute_solve(input(), 10_007, 50) == 8763
#    assert Day22.brute_solve(input(), 10_007, 100) == 3801
  end

  test "part 2 with my input" do
    assert Day22.part2(input()) == 27697279941366
  end

  defp example1() do
    """
    deal with increment 7
    deal into new stack
    deal into new stack
    """
    |> s()
  end

  defp example2() do
    """
    deal with increment 7
    deal with increment 9
    cut -2
    """
    |> s()
  end

  defp example3() do
    """
    deal into new stack
    cut -2
    deal with increment 7
    cut 8
    cut -4
    deal with increment 7
    cut 3
    deal with increment 9
    deal with increment 3
    cut -1
    """
    |> s()
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
  end

  defp s(string) do
    string
    |> String.trim
    |> String.split("\n")
  end
end
