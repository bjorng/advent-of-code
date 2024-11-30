defmodule Day18 do
  def part1 lines do
    board = parse_input lines
    stream = resource_stream board
    Enum.at(stream, 10)
  end

  def part2 lines do
    board = parse_input lines
    stream = resource_stream board
    minutes = 1000000000

    # Find a cycle. Trying to find the cycle using the infinite stream
    # is too slow because there is no memoization.
    #
    # Therefore I cheat a little and get a smallish finite
    # slice out of the infinite stream. This works with my input data,
    # but may not work with other input data.

    stream = Enum.take(stream, 2000)
    {lambda, mu} = find_cycle stream

    # For my input data, the cycle starts after 452 minutes and the
    # cycle length is 28.

    IO.inspect {lambda, mu}
    values = {lambda, mu, Enum.take(Enum.drop(stream, mu), lambda)}

    # The following is an assertion to check that the predicted
    # values based on the cycle agrees with the actual values.

    Enum.each(mu + lambda..mu + lambda + 100, fn minutes ->
      value = get_resource_value(values, minutes)
      ^value = Enum.at(stream, minutes)
    end)

    # Now get the predicted value.

    get_resource_value values, minutes
  end

  defp get_resource_value {lambda, mu, values}, minutes do
    Enum.at(values, rem(minutes - mu, lambda))
  end

  defp resource_stream board do
    Stream.unfold(board, fn acc ->
      {value(acc), transform(acc)}
    end)
  end

  # Brent's algorithm for finding cycles.
  #
  # https://en.wikipedia.org/wiki/Cycle_detection

  defp find_cycle stream do
    lambda = find_lambda(stream, Stream.drop(stream, 1), 1, 1)
    hare = Stream.drop stream, lambda
    mu = find_mu(stream, hare, 0)
    {lambda, mu}
  end

  # Find cycle length (lambda)

  defp find_lambda(tortoise, hare, power, lambda) do
    case Enum.take(tortoise, 1) == Enum.take(hare, 1) do
      true ->
	lambda
      false ->
	if power == lambda do
	  find_lambda(hare, Stream.drop(hare, 1), power*2, 1)
	else
	  find_lambda(tortoise, Stream.drop(hare, 1), power, lambda+1)
	end
    end
  end

  # Find the zero-based index of the start of the cycle (mu)

  defp find_mu tortoise, hare, mu do
    # Since the values in the sequence are not guaranteed to be
    # unique, we might find a false start of the cycle.
    # Therefore, check that the values for two minutes agree.
    #
    # This works for my input data, but may not work in general.

    case Enum.at(tortoise, mu) == Enum.at(hare, mu) &&
      Enum.at(tortoise, mu + 1) == Enum.at(hare, mu + 1) do
      true -> mu
      false -> find_mu tortoise, hare, mu + 1
    end
  end

  defp value board do
    board
    |> Enum.reduce({0, 0}, fn {_, item}, {wooded, lumberyards} ->
      case item do
	:trees ->
	  {wooded + 1, lumberyards}
	:lumberyard ->
	  {wooded, lumberyards + 1}
	:open ->
	  {wooded, lumberyards}
      end
    end)
    |> (fn {wooded, lumberyards} ->
      {wooded, lumberyards, wooded * lumberyards}
    end).()
  end

  defp transform old_board do
    Enum.reduce(old_board, old_board, fn {pos, item}, acc ->
      count = count_adjacent(old_board, pos)
      case item do
	:open ->
	  if count.trees >= 3 do
	    %{acc | pos => :trees}
	  else
	    acc
	  end
	:trees ->
	  if count.lumberyard >= 3 do
	    %{acc | pos => :lumberyard}
	  else
	    acc
	  end
	:lumberyard ->
	  unless count.lumberyard >= 1 and count.trees >= 1 do
	    %{acc | pos => :open}
	  else
	    acc
	  end
      end
    end)
  end

  defp count_adjacent board, {x, y} do
    adjacent = [{x-1, y-1}, {x, y-1}, {x + 1, y - 1},
		{x-1, y},             {x + 1, y},
		{x-1, y+1}, {x, y+1}, {x + 1, y + 1}]
    adjacent
    |> Enum.map(fn pos ->
      Map.get(board, pos, :outside)
    end)
    |> Enum.group_by(&(&1))
    |> Enum.map(fn {key, items} -> {key, length(items)} end)
    |> Enum.into(%{})
    |> (fn map -> Map.merge(%{trees: 0, lumberyard: 0, open: 0}, map) end).()
  end

  defp parse_input lines do
    lines
    |> Stream.with_index
    |> Enum.reduce(%{}, fn {line, row}, acc ->
      map = String.to_charlist(line)
      |> Stream.with_index
      |> Enum.map(fn {char, col} ->
	{{row, col}, case char do
		       ?. -> :open
		       ?| -> :trees
		       ?\# -> :lumberyard
		     end}
      end)
      |> Enum.into(%{})
      Map.merge(map, acc)
    end)
  end

  def print_board board do
    {{max, _}, _} = Enum.max(board)
    range = 0..max
    IO.puts ""
    Enum.each(range, fn row ->
      IO.puts Enum.map(range, fn col ->
	pos = {row, col}
	case board[pos] do
	  :open -> ?.
	  :lumberyard -> ?\#
	  :trees -> ?|
	end
      end)
    end)
    IO.puts ""
    board
  end

end
