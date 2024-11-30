defmodule Day23 do
  def part1(input, moves \\ 100), do: Day23Part1.part1(input, moves)
  def part2(input, moves \\ 10_000_000), do: Day23Part2.part2(input, moves)
end

defmodule Day23Part2 do
  @limit 1_000_000

  def part2(input, moves) do
    circle = parse(input)
    |> add_rest
    |> init_circle

    move(circle, moves)
  end

  defp add_rest(input), do: input ++ :lists.seq(10, @limit)

  defp move(circle, 0) do
    circle = make_current(circle, 1)
    {[cup1, cup2, _], _} = pick_three(circle)
    IO.inspect {cup1, cup2}
    cup1 * cup2
  end
  defp move(circle, n) do
    if (rem(n, 100_000) === 0) do
      :io.format("\r~p ", [n])
    end

    {cups, circle} = pick_three(circle)
    current = get_current(circle)
    destination = get_destination(current, cups)
    put_back(circle, destination, cups)
    |> new_current
    |> move(n - 1)
  end

  defp get_destination(0, _cups), do: 9
  defp get_destination(label, cups) do
    label =
      case label - 1 do
        0 -> @limit
        label -> label
    end
    case label in cups do
      true -> get_destination(label, cups)
      false -> label
    end
  end

  defp init_circle(list) do
    s1 = Stream.cycle(list)
    s2 = Stream.drop(s1, 1)
    Stream.zip([s1, s2])
    |> Stream.map(fn {current, next} ->
      {current, next}
    end)
    |> Enum.take(length(list))
    |> Map.new
    |> Map.put(:current, hd(list))
  end

  defp pick_three(circle) do
    current = get_current(circle)
    picks = circle_take(circle, current, 3)
    last = List.last(picks)
    circle = circle_unlink(circle, current, last)
    {picks, circle}
  end

  defp get_current(circle) do
    Map.get(circle, :current)
  end

  defp put_back(circle, destination, list) do
    next = circle_next(circle, destination)
    first = hd(list)
    last = List.last(list)
    %{circle | destination => first, last => next}
  end

  defp new_current(circle) do
    current = get_current(circle)
    current = circle_next(circle, current)
    Map.put(circle, :current, current)
  end

  defp make_current(circle, label) do
    case get_current(circle) do
      ^label -> circle
      _ -> make_current(new_current(circle), label)
    end
  end

  defp circle_next(circle, label) do
    Map.get(circle, label)
  end

  defp circle_unlink(circle, previous, last) do
    Map.put(circle, previous, Map.get(circle, last))
  end

  defp circle_take(_circle, _label, 0), do: []
  defp circle_take(circle, label, n) do
    next = Map.get(circle, label)
    [next | circle_take(circle, next, n - 1)]
  end

  defp parse(input) do
    Integer.to_string(input)
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
  end
end

#
# Part 1.
#

defmodule Day23Part1 do
  def part1(input, moves) do
    parse(input)
    |> init_circle
    |> Stream.iterate(&move/1)
    |> Stream.drop(moves)
    |> Enum.take(1)
    |> hd
    |> result
  end

  defp result(circle) do
    make_current(circle, 1)
    |> circle_to_list
    |> tl
    |> Enum.reduce(0, fn digit, acc ->
      acc * 10 + digit
    end)
  end

  defp move(circle) do
    {cups, circle} = pick_three(circle)
    current = get_current(circle)
    destination = get_destination(current, cups)
    put_back(circle, destination, cups)
    |> new_current
  end

  defp get_destination(0, _cups), do: 9
  defp get_destination(label, cups) do
    label =
      case label - 1 do
        0 -> 9
        label -> label
    end
    case label in cups do
      true -> get_destination(label, cups)
      false -> label
    end
  end

  defp init_circle(list) do
    {[], list}
  end

  defp pick_three({left, [current, one, two, three | tail]}) do
    {[one, two, three], {left, [current | tail]}}
  end
  defp pick_three({left, right}) do
    [current, one, two, three | tail] = right ++ Enum.reverse(left)
    {[one, two, three], {[], [current | tail]}}
  end

  defp get_current({_left, [current | _]}), do: current
  defp get_current({[current | _], []}), do: current

  defp put_back({left, right}, label, list) do
    case Enum.find_index(right, &(&1 === label)) do
      nil ->
        index = Enum.find_index(left, &(&1 === label))
        left = insert_list_at(left, index, Enum.reverse(list))
        {left, right}
      index ->
        right = insert_list_at(right, index + 1, list)
        {left, right}
    end
  end

  defp insert_list_at(tail, 0, list), do: list ++ tail
  defp insert_list_at([head | tail], n, list) do
    [head | insert_list_at(tail, n - 1, list)]
  end

  defp new_current({left, [old_current | tail]}) do
    {[old_current | left], tail}
  end

  defp make_current(circle, label) do
    case get_current(circle) do
      ^label -> circle
      _ -> make_current(new_current(circle), label)
    end
  end

  defp circle_to_list({left, right}) do
    right ++ Enum.reverse(left)
  end

  defp parse(input) do
    Integer.to_string(input)
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
  end
end
