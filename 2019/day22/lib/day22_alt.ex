# In this module I have implemented alternate solutions based on
# solutions found in the subreddit for AOC.

defmodule Day22Alt do
  use Bitwise

  def solve(input, deck_size, iterations, target) do
    result = solve_mathy(input, deck_size, iterations, target)
    ^result = solve_no_math(input, deck_size, iterations, target)
  end

  def solve_mathy(input, deck_size, iterations, target) do
    {a, b} = find_coefficients(input, deck_size)

    # This is the same calculation as in Day22.lazy_solve_v3/4
    # but with different variable names.
    #
    # b * (a^(deck_size+1) - 1) / (a - 1) + d^4 * target

    a_pow_iters = mod_int_pow(a, iterations, deck_size)
    inv = mod_inv(a - 1, deck_size)
    res = b * rem((a_pow_iters - 1) * inv, deck_size) + a_pow_iters * target
    positive_rem(res, deck_size)
  end

  # Position target came from a*q + b. Find a and b.
  defp find_coefficients([first | rest], deck_size) do
    {a, b} = find_coefficients(rest, deck_size)
    case first do
      {:cut, inc} ->
        {a, b + inc}
      :deal ->
        {-a, -b - 1}
      {:deal, inc} ->
        inv = mod_inv(inc, deck_size)
        {a * inv, b * inv}
    end
  end
  defp find_coefficients([], _deck_size), do: {1, 0}

  # https://www.reddit.com/r/adventofcode/comments/ee56wh/2019_day_22_part_2_so_whats_the_purpose_of_this/fbr0vjb/?context=3
  # https://github.com/GreenLightning/aoc19/blob/95ebfd5ee9a3def42cfe7558c5c23a3d821ca2c5/day22/main.go

  def solve_no_math(input, deck_size, iterations, target) do
    compact(input, deck_size)
    |> action_pow(deck_size, deck_size - iterations - 1)
    |> Enum.reduce(target, fn technique, pos ->
      case technique do
        {:cut, inc} ->
          positive_rem(pos - inc, deck_size)
        :deal ->
          positive_rem(deck_size - 1 - pos, deck_size)
        {:deal, inc} ->
          positive_rem(pos * inc, deck_size)
      end
    end)
  end

  defp action_pow(actions, deck_size, iters) do
    action_pow(actions, deck_size, iters, [])
  end

  defp action_pow(_actions, _deck_size, 0, acc), do: acc
  defp action_pow(actions, deck_size, iters, acc) do
    new_actions = compact(actions ++ actions, deck_size)
    new_iters = div(iters, 2)
    case rem(iters, 2) do
      0 ->
        action_pow(new_actions, deck_size, new_iters, acc)
      1 ->
        action_pow(new_actions, deck_size, new_iters, acc ++ actions)
    end
  end

  defp compact(actions, deck_size) do
    actions = do_compact(actions, deck_size)
    if length(actions) <= 3 do
      actions
    else
      compact(actions, deck_size)
    end
  end

  # Compact "deal into stack" shuffles.
  #
  # Two consecutive "deal into stack" shuffles cancel each other. So
  # we iterate over the input list, tracking whether we need to
  # currently need reverse the stack, which changes every time we see
  # a "deal into stack" shuffle. Then, if we need to reverse at the
  # end, we add a single "deal into stack" shuffle to the output.
  #
  # If we currently need to reverse the stack, we have to modify the
  # other shuffles. This boils down to the following two rules, where
  # the list of instructions below the line has the same effect as the
  # list of instructions above the line:
  #
  # deal into new stack
  # deal into new stack
  # -------------------
  # (nothing)
  #
  # deal into new stack
  # cut x
  # -------------------
  # cut count-x
  # deal into new stack
  #
  # deal into new stack
  # deal with increment x
  # ---
  # deal with increment x
  # cut count+1-x
  # deal into new stack
  #
  # Compact "cut" shuffles.
  #
  # Here we require that the "deal into stack" shuffles have been compacted
  # already, so we can insert the "cut" shuffle before the "deal into
  # stack" shuffle or at the end. Then, we only have to handle "deal with
  # increment" shuffles.
  #
  # cut x
  # cut y
  # ---
  # cut (x+y) % count
  #
  # cut x
  # deal with increment y
  # ---
  # deal with increment y
  # cut (x*y) % count
  #
  # Compact "deal with increment" shuffles.
  #
  # Finally, we just have to combine "deal with increment" shuffles.
  #
  # deal with increment x
  # deal with increment y
  # ---
  # deal with increment (x*y) % count

  # Compact "deal into stack" shuffles.
  defp do_compact([:deal, :deal | rest], deck_size) do
    do_compact(rest, deck_size)
  end
  defp do_compact([:deal, {:cut, cut}| rest], deck_size) do
    do_compact([{:cut, positive_rem(deck_size - cut, deck_size)},
                :deal | rest], deck_size)
  end
  defp do_compact([:deal, {:deal, inc}| rest], deck_size) do
    do_compact([{:deal, inc},
                {:cut, positive_rem(deck_size + 1 - inc, deck_size)},
                :deal | rest], deck_size)
  end

  # Compact "cut" shuffles.
  defp do_compact([{:cut, cut1}, {:cut, cut2} | rest], deck_size) do
    do_compact([{:cut, positive_rem(cut1 + cut2, deck_size)} | rest], deck_size)
  end
  defp do_compact([{:cut, cut}, {:deal, inc}| rest], deck_size) do
    do_compact([{:deal, inc}, {:cut, positive_rem(cut * inc, deck_size)} | rest], deck_size)
  end

  # Compact "deal with increment" shuffles.
  defp do_compact([{:deal, inc1}, {:deal, inc2}| rest], deck_size) do
    do_compact([{:deal, positive_rem(inc1 * inc2, deck_size)} | rest], deck_size)
  end

  # Handle incompatible item and end of shuffles.
  defp do_compact([first | rest], deck_size) do
    [first | do_compact(rest, deck_size)]
  end
  defp do_compact([], _deck_size), do: []

  defp positive_rem(n, deck_size) do
    n = rem(n, deck_size)
    if n < 0, do: positive_rem(n + deck_size, deck_size), else: n
  end

  @doc """
  Return x such that rem(x * a, p) == 1.
  p must be prime and a must not be divisible by p.

  ## Examples:

      iex> Day22.mod_inv(7, 23)
      10
      iex> rem(div(777, 7), 23)
      19
      iex> rem(777 * Day22.mod_inv(7, 23), 23)
      19
  """

  def mod_inv(a, p) do
    # This implementation is based on Fermat's little theorem:
    #
    #     a^(p-1) ≡ 1   (mod p)
    #
    # where p is prime and a is not divisible by p.
    #
    # This can be rewritten to:
    #
    #     a^(p-2) * a ≡ 1 (mod p)
    #
    # Thus it can be seen that the modular multiplicative inverse
    # of a is a^(p-2).
    x = mod_int_pow(a, p - 2, p)
    1 = rem(a * x, p)           # Assertion
    x
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
end

