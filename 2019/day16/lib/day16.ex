defmodule Day16 do
  def part1(input) do
    list = parse(input)
    rounds(lazy_dup(list, 1), 100)
    |> Enum.take(8)
    |> Enum.map(& &1 + ?0)
    |> to_string
  end

  def part2(input) do
    list = parse(input)
    offset = String.to_integer(String.slice(input, 0, 7))

    # Assertion. The offset must be in the second half.
    true = 2 * offset >= byte_size(input) * 10_000

    Stream.cycle(list)
    |> Stream.drop(offset)
    |> Enum.take(byte_size(input) * 10_000 - offset)
    |> Stream.iterate(&next_round/1)
    |> Enum.at(100)
    |> Enum.take(8)
    |> Enum.map(& &1 + ?0)
    |> to_string
  end

  defp next_round(list) do
    {digits, _} = do_next_round(list)
    digits
  end

  defp do_next_round([h | t]) do
    {digits, sum} = do_next_round(t)
    {[rem(abs(h + sum), 10) | digits], sum + h}
  end
  defp do_next_round([]), do: {[], 0}

  #
  # The rest is code for part 1. The lazy lists was an attempt
  # to optimize part 2. Turned out that part 2 could be solved
  # simpler.
  #

  @base_pattern [0, 1, 0, -1]

  defp rounds(list, 0), do: lazy_get_list(list)
  defp rounds(list, n) do
    rounds(one_round(list), n - 1)
  end

  defp one_round(list) do
    {result, remaining} = 1..lazy_len(list)
    |> Enum.map_reduce(list, fn index, reduced_list ->
      gen_pattern(index)
      |> Enum.reduce_while({0, reduced_list}, fn {pat, num}, {sum, acc} ->
	{sum,acc} = case pat do
		      0 ->
			{sum, lazy_drop(acc, num)}
		      _ ->
			{new_sum, acc} = lazy_sum_drop(acc, 0, num)
			{sum + new_sum * pat, acc}
		    end
	case lazy_empty?(acc) do
	  true -> {:halt, {rem(abs(sum), 10), lazy_tl(reduced_list)}}
	  false -> {:cont, {sum, acc}}
	end
      end)
    end)
    true = lazy_empty?(remaining)
    lazy_dup(result, 1)
  end

  defp lazy_dup(list, n) do
    clen = length(list)
    {list, list, clen, clen, n - 1}
  end

  defp lazy_len({_list, _original, len, clen, num_more}) do
    len + num_more * clen
  end

  defp lazy_empty?(list), do: list === :empty_list

  defp lazy_drop({list, original, len, clen, num_more}, n) do
    case n >= len do
      true ->
	case num_more do
	  0 ->
	    :empty_list
	  _ ->
	    left = n - len
	    lazy_drop({original, original, clen, clen, num_more - 1}, left)
	end
      false ->
	rest = Enum.drop(list, n)
	{rest, original, len - n, clen, num_more}
    end
  end

  defp lazy_tl({[_ | []], _original, _len, _clen, 0}), do: :empty_list
  defp lazy_tl({[_ | tl], original, len, clen, num_more}) do
    {tl, original, len - 1, clen, num_more}
  end
  defp lazy_tl({[], original, 0, clen, num_more}) do
    true = num_more > 0
    {original, original, clen, clen, num_more - 1}
  end

  defp lazy_sum_drop(list, sum, 0), do: {sum, list}
  defp lazy_sum_drop({[], _original, _len, _clen, 0}, sum, _), do: {sum, :empty_list}
  defp lazy_sum_drop({list, original, len, clen, num_more}, sum, n) do
    case sum_drop(list, sum, n) do
      {sum, []} ->
	case num_more do
	  0 ->
	    {sum, :empty_list}
	  _ ->
	    left = n - len
	    lazy_sum_drop({original, original, 0, clen, num_more - 1}, sum, left)
	end
      {sum, [_|_] = rest} ->
	{sum, {rest, original, len - n, clen, num_more}}
    end
  end

  defp sum_drop(els, sum, 0), do: {sum, els}
  defp sum_drop([], sum, _), do: {sum, []}
  defp sum_drop([el | els], sum, n) do
    sum_drop(els, sum + el, n - 1)
  end

  defp lazy_get_list(:empty_list), do: []
  defp lazy_get_list({list, _original, _len, _clen, _}), do: list

  defp gen_pattern(index) do
    first = Enum.map(tl(@base_pattern), & {&1, index})

    cycles = @base_pattern
    |> Enum.map(& {&1, index})
    |> Stream.cycle

    Stream.concat(first, cycles)
  end

  defp parse(input) do
    to_charlist(input)
    |> Enum.map(&(&1 - ?0))
  end
end
