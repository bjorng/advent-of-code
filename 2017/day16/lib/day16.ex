defmodule Day16 do
  def part1(input, num_programs) do
    line_after_dances(1, input, num_programs)
    |> Enum.to_list
    |> to_string
  end

  def part2(input, num_programs) do
    line_after_dances(1_000_000_000, input, num_programs)
    |> Enum.to_list
    |> to_string
  end

  defp line_after_dances(num_dances, input, num_programs) do
    Enum.reduce_while(
      all_lines(input, num_programs) |> Stream.with_index(),
      {%{}, %{}},
      fn
	{line, ^num_dances}, _cache ->
	  {:halt, line}
      {current_line, current_dance}, {line_to_dance, dance_to_line} ->
	case Map.fetch(line_to_dance, current_line) do
	  :error ->
	    {:cont, {Map.put(line_to_dance, current_line, current_dance),
		     Map.put(dance_to_line, current_dance, current_line)}}
	  {:ok, cycle_start} ->
	    cycle_length = current_dance - cycle_start
            {:halt, Map.fetch!(dance_to_line, cycle_start + rem(num_dances - cycle_start, cycle_length))}
	end
      end)
  end

  defp all_lines(string, num_programs) do
    moves = parse(string)
    line = Enum.to_list(?a..(?a+num_programs-1))
    Stream.iterate(line, fn line -> dance(line, moves, num_programs) end)
  end

  defp dance(line, [{:split, position} | moves], num_programs) do
    {first, last} = Enum.split(line, num_programs - position)
    line = last ++ first
    dance(line, moves, num_programs)
  end
  defp dance(line, [{:exchange, position1, position2} | moves], num_programs) do
    line = exchange(line, position1, position2 - position1 - 1)
    dance(line, moves, num_programs)
  end
  defp dance(line, [{:partner, program1, program2} | moves], num_programs) do
    line = partner(line, program1, program2)
    dance(line, moves, num_programs)
  end
  defp dance(line, [], _num_programs), do: line

  defp exchange([h | t], 0, second) do
    exchange_rest(t, h, second, [])
  end
  defp exchange([h | t], first, second) do
    [h | exchange(t, first - 1, second)]
  end

  defp exchange_rest([p2 | t], p1, 0, acc) do
    [p2 | Enum.reverse(acc, [p1 | t])]
  end
  defp exchange_rest([h | t], p1, pos, acc) do
    exchange_rest(t, p1, pos - 1, [h | acc])
  end

  defp partner([p1 | t], p1, p2) do
    partner_rest(t, p2, p1, [])
  end
  defp partner([p2 | t], p1, p2) do
    partner_rest(t, p1, p2, [])
  end
  defp partner([h | t], p1, p2) do
    [h | partner(t, p1, p2)]
  end

  defp partner_rest([p2 | t], p2, p1, acc) do
    [p2 | Enum.reverse(acc, [p1 | t])]
  end
  defp partner_rest([h | t], p2, p1, acc) do
    partner_rest(t, p2, p1, [h | acc])
  end

  defp parse(string) do
    {:ok, result, "", _, _, _} = DanceParser.moves(string)
    parse_post_process(result)
  end

  defp parse_post_process(list) do
    case list do
      [?s, position | tail] ->
	[{:split, position} | parse_post_process(tail)]
      [?x, position1, position2 | tail] ->
	false = position1 === position2
	op = case position1 < position2 do
	       true -> {:exchange, position1, position2}
	       false -> {:exchange, position2, position1}
	     end
	[op | parse_post_process(tail)]
      [?p, program1, program2 | tail] ->
	false = program1 === program2
	[{:partner, program1, program2} | parse_post_process(tail)]
      [] ->
	[]
    end
  end
end

defmodule DanceParser do
  import NimbleParsec

  position = integer(min: 1)
  spin_length = integer(min: 1)
  program = ascii_char([?a..?p])
  comma = ignore(string(","))
  slash = ignore(string("/"))

  spin = concat(ascii_char([?s]), spin_length)
  exchange = concat(ascii_char([?x]),
    concat(position, concat(slash, position)))
  partner = concat(ascii_char([?p]), concat(program, concat(slash, program)))

  move = choice([spin, exchange, partner]) |> optional(comma)
  moves = repeat(move)

  defparsec :moves, moves
end
