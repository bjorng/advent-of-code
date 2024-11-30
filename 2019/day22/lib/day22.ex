#
# I solved this problem by myself without looking at hints in the AOC
# subreddit. By reading the comments for the solvers in the code
# below, you can see how I approached and finally designed a solver
# that would solve the full problem for part 2 in reasonable time
# (in 0.05 seconds on my computer).
#
defmodule Day22 do
  use Bitwise

  def part1(input, deck_size \\ 10_007) do
    input = parse_input(input)
    deck = 0..deck_size-1 |> Enum.to_list
    deck = Enum.reduce(input, deck, fn technique, acc ->
      one_step(technique, acc, deck_size)
    end)
    case deck_size do
      10_007 ->
        # Find the solution for part 1.
        Enum.find_index(deck, & &1 === 2019)
      _ ->
        # Called from a test. Return the deck.
        deck
    end
  end

  @part2_position 2020

  def part2(input) do
    # Solve part 2 using the fastest solver.
    deck_size = 119_315_717_514_047
    times = 101_741_582_076_661
    card = lazy_solve_v3(input, deck_size, times)

    # Test solvers inspired by solutions in the subreddit.
    input = parse_input(input)
    ^card = Day22Alt.solve(input, deck_size, times, @part2_position)
  end

  # Solve part 2 using brute force, i.e. by starting with a deck in
  # factory order and iterate the techniques the chosen number of
  # times and then look at the card at the target location. Only
  # smallish deck sizes and number of iterations can be solved this
  # way, but it will help us verify the correctness of the faster
  # solver algorithms.

  def brute_solve(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    brute_stream(input, deck_size)
    |> Stream.drop(times)
    |> Enum.take(1)
    |> hd
    |> Enum.at(target)
  end

  defp brute_stream(input, deck_size) do
    input = parse_input(input)
    deck = 0..deck_size-1 |> Enum.to_list
    Stream.iterate(deck, & next_brute(input, &1, deck_size))
  end

  defp next_brute(input, deck, deck_size) do
    Enum.reduce(input, deck, fn technique, acc ->
      one_step(technique, acc, deck_size)
    end)
  end

  #
  # Solve the same problem using all versions of the
  # faster solvers and verify that they all return the
  # same result.
  #

  def lazy_solve(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    card = lazy_solve_v1(input, deck_size, times, target)
    ^card = lazy_solve_v2(input, deck_size, times, target)
    ^card = lazy_solve_v3(input, deck_size, times, target)

    # Test solvers inspired solutions in the subreddit.
    input = parse_input(input)
    ^card = Day22Alt.solve(input, deck_size, times, target)
  end

  #
  # This solver algorithm can handle a deck of any size. It will apply
  # the techniques in reverse order and "backwards" on the target
  # position. It will not solve a problem with a huge number of
  # iterations in reasonable time, because the effort is proportional
  # to the number of iterations.
  #

  def lazy_solve_v1(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    input = parse_input(input)
    input = Enum.reverse(input)
    input = prepare_lazy_input(input, deck_size)
    Stream.iterate(target, & solve_one(input, deck_size, &1))
    |> Stream.drop(times)
    |> Enum.take(1)
    |> hd
  end

  #
  # This solver algorithm takes advantage of linearity.
  # The previous position can be calculated using the
  # following expression:
  #
  #      rem(zero + diff * target, deck_size)
  #
  # The constants zero and diff could be calculated from
  # the techniques in the input, but I calculate them by running
  # the v1 solver twice.
  #
  # This algorithm is faster than v1, but it is still proportional
  # to the number of iterations (albeit with a smaller constant
  # factor), so it still can't solve part 2 in reasonable time.
  #

  def lazy_solve_v2(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    zero = lazy_solve_v1(input, deck_size, 1, 0)
    one = lazy_solve_v1(input, deck_size, 1, 1)
    diff = positive_rem(one - zero, deck_size)
    do_lazy_solve_v2(target, zero, diff, deck_size, times)
  end

  defp do_lazy_solve_v2(target, _, _, _, 0), do: target
  defp do_lazy_solve_v2(target, zero, diff, deck_size, times) do
    target = rem(zero + diff * target, deck_size)
    do_lazy_solve_v2(target, zero, diff, deck_size, times - 1)
  end

  #
  # This version of the algorithm is derived by rewriting
  # the formula from v2. Looking at four iterations, we
  # have (shorting the variable names):
  #
  #     z + d * (z + d * (z + d * (z + d*target)))
  #
  # By multiplying the d's into the parentheses, we get:
  #
  #     z + d*z + d^2 * (z + d * (z + d*target))
  #     z + d*z + d^2*z + d^3 * (z + d*target)
  #     z + d*z + d^2*z + d^3*z + d^4*target
  #
  # By breaking out z, we get:
  #
  #     z * (1 + d + d^2 + d^3) + d^4*target
  #
  # There is closed form expression for the expression inside
  # the parentheses, namely:
  #
  #     (x^(n+1) - 1) / (x - 1)
  #
  # I found this closed form by inputting the following
  # query to WolframAlpha:
  #
  #     sum x^k, k=0 to n
  #
  # Thus the entire expression is:
  #
  #     z * (x^(n+1) - 1) / (x - 1) + d^4*target
  #
  # The expression should be evaluated modulo the size of the deck.
  # To do the division with modulo arithmetic, we'll need to find
  # the modular multiplicative inverse and multiply by it. To find
  # the inverse, I first implemented the extended Euclidean algorithm.
  #
  # I based my implementation on the Haskell version on this web page:
  #
  # https://en.wikibooks.org/wiki/Algorithm_Implementation/Mathematics/Extended_Euclidean_algorithm
  #

  def lazy_solve_v3(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    zero = lazy_solve_v1(input, deck_size, 1, 0)
    one = lazy_solve_v1(input, deck_size, 1, 1)
    diff = positive_rem(one - zero, deck_size)
    diff_pow_times = mod_int_pow(diff, times, deck_size)
    inv = mod_inv(diff - 1, deck_size)
    res = rem((diff_pow_times - 1) * inv, deck_size)
    res = zero * res + diff_pow_times * target
    positive_rem(res, deck_size)
  end

  @doc """
  Raise an integer to a power with modulus.

  ## Examples:

      iex> Day22.mod_int_pow(7, 2, 10)
      9
      iex> Day22.mod_int_pow(7, 3, 10)
      3
      iex> Day22.mod_int_pow(7, 5, 13)
      11
      iex> Day22.mod_int_pow(53, 13, 777)
      305
  """

  def mod_int_pow(x, p, m, res \\ 1)
  def mod_int_pow(_, 0, _, res), do: res
  def mod_int_pow(x, p, m, res) do
    next_x = rem(x * x, m)
    next_p = bsr(p, 1)
    case band(p, 1) do
      0 ->
        mod_int_pow(next_x, next_p, m, rem(res, m))
      1 ->
        mod_int_pow(next_x, next_p, m, rem(res*x, m))
    end
  end

  @doc """
  Return x such that rem(x * a, b) == 1. a and b must
  be relative primes.

  ## Examples:

      iex> Day22.mod_inv(7, 23)
      10
      iex> rem(div(777, 7), 23)
      19
      iex> rem(777 * Day22.mod_inv(7, 23), 23)
      19
  """

  def mod_inv(a, b) do
    {1, x, _} = egcd(a, b)
    rem(b + x, b)
  end

  @doc """
  Extended gcd algorithm. Return the greatest common
  divisor, g, as well as s and t, which are numbers such that:

     a*s + b*t = g = gcd(a, b)


  ## Examples:

      iex> Day22.egcd(12, 18)
      {6, -1, 1}
  """

  def egcd(0, b), do: {b, 0, 1}
  def egcd(a, b) do
    {g, s, t} = egcd(rem(b, a), a)
    {g, t - div(b, a) *s, s}
  end

  defp positive_rem(n, deck_size) do
    n = rem(n, deck_size)
    if n < 0, do: positive_rem(n + deck_size, deck_size), else: n
  end

  defp solve_one(input, deck_size, target) do
    Enum.reduce(input, target, fn technique, acc ->
      lazy_step(technique, acc, deck_size)
    end)
  end

  defp lazy_step({:cut_deal, n}, pos, size) do
    rem(size + n - pos, size)
  end
  defp lazy_step({:cut, n}, pos, size) do
    rem(size + pos + n, size)
  end
  defp lazy_step({:deal, inc, deal_map}, target, size) do
    target_rem = rem(inc - rem(target, inc), inc)
    n = Map.fetch!(deal_map, target_rem)
    div(n * size + target, inc)
  end

  defp prepare_lazy_input([{:cut, n}, :deal | input], deck_size) do
    [{:cut_deal, -n - 1} | prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([:deal, {:cut, n} | input], deck_size) do
    [{:cut_deal, n - 1} | prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([:deal | input], deck_size) do
    [{:cut_deal, -1} | prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([{:deal, inc} | input], deck_size) do
    [{:deal, inc, make_deal_map(inc, deck_size)} |
     prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([technique | input], deck_size) do
    [technique | prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([], _), do: []

  defp make_deal_map(inc, deck_size) do
    rem_delta = rem(deck_size, inc)
    make_deal_map(inc, rem_delta, 0, 0, [])
  end

  defp make_deal_map(inc, _rem_delta, _sum, inc, acc) do
    Map.new(acc)
  end
  defp make_deal_map(inc, rem_delta, sum, n, acc) when sum >= inc do
    make_deal_map(inc, rem_delta, rem(sum, inc), n, acc)
  end
  defp make_deal_map(inc, rem_delta, sum, n, acc) do
    make_deal_map(inc, rem_delta, sum + rem_delta, n + 1, [{sum, n} | acc])
  end

  defp one_step(:deal, deck, _deck_size) do
    Enum.reverse(deck)
  end
  defp one_step({:deal, inc}, deck, deck_size) do
    {numbered, _} = Enum.map_reduce(deck, 0, fn card, index ->
      {{rem(index, deck_size), card}, index + inc}
    end)
    Enum.sort(numbered) |> Enum.map(fn {_, card} -> card end)
  end
  defp one_step({:cut, n}, deck, deck_size) do
    if n < 0 do
      {first, rest} = Enum.split(deck, deck_size + n)
      rest ++ first
    else
      {first, rest} = Enum.split(deck, n)
      rest ++ first
    end
  end

  defp parse_input(input) do
    Enum.map(input, fn line ->
      case line do
        "deal into new stack" ->
          :deal
        "deal with increment " <> int ->
          {:deal, String.to_integer(int)}
        "cut " <> int ->
          {:cut, String.to_integer(int)}
      end
    end)
  end
end
