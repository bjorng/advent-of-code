defmodule Day14 do
  def part1(input) do
    num_recipes = String.to_integer(input)
    stream = recipe_stream 3, 7
    stream
    |> Stream.drop(num_recipes)
    |> Stream.take(10)
    |> Enum.to_list
    |> Enum.map(&(&1 + ?0))
    |> List.to_integer
  end

  # Fast solution.
  def part2 pattern do
    pattern =
      pattern
      |> String.to_charlist
      |> Enum.map(&(&1 - ?0))
      |> List.to_string
    s = <<3, 7>>
    cur1 = 0
    cur2 = 1
    pat_len = byte_size(pattern)
    find s, cur1, cur2, pattern, pat_len
  end

  def find(recipes, cur1, cur2, pat, pat_len) when byte_size(recipes) < 5 do
    next = :binary.at(recipes, cur1) + :binary.at(recipes, cur2)
    new_recipes = Enum.map(Integer.to_charlist(next), &(&1 - ?0))
    recipes = <<recipes::binary, :erlang.list_to_binary(new_recipes)::binary>>
    size = byte_size recipes
    cur1 = rem(cur1 + 1 + :binary.at(recipes, cur1), size)
    cur2 = rem(cur2 + 1 + :binary.at(recipes, cur2), size)
    find recipes, cur1, cur2, pat, pat_len
  end

  def find(recipes, cur1, cur2, pat, pat_len) do
    next = :binary.at(recipes, cur1) + :binary.at(recipes, cur2)
    if next < 10 do
      recipes = <<recipes::binary, next>>
      size = byte_size recipes
      cur1 = rem(cur1 + 1 + :binary.at(recipes, cur1), size)
      cur2 = rem(cur2 + 1 + :binary.at(recipes, cur2), size)
      case binary_part(recipes, size, -pat_len) do
	^pat ->
	  size - pat_len
	_part ->
	  find recipes, cur1, cur2, pat, pat_len
      end
    else
      recipes = <<recipes::binary, div(next, 10), next - 10>>
      size = byte_size recipes
      cur1 = rem(cur1 + 1 + :binary.at(recipes, cur1), size)
      cur2 = rem(cur2 + 1 + :binary.at(recipes, cur2), size)
      case binary_part(recipes, size, -pat_len) do
	^pat ->
	  size - pat_len
	_part ->
	  case binary_part(recipes, size - 1, -pat_len) do
	    ^pat ->
	      size - pat_len - 1
	    _ ->
	      find recipes, cur1, cur2, pat, pat_len
	  end
      end
    end
  end

  # This solution that uses a stream is far too slow
  # (at least for my input).
  def part2_slow pattern do
    stream = recipe_stream 3, 7
    pattern = String.to_charlist(pattern)
    |> Enum.map(&(&1 - ?0))
    IO.inspect pattern
    match_stream stream, pattern, length(pattern), 0
  end

  defp match_stream stream, pattern, pat_len, count do
    case Stream.take(stream, pat_len) |> Enum.to_list do
      ^pattern ->
	count
      _taken ->
	match_stream Stream.drop(stream, 1), pattern, pat_len, count + 1
    end
  end

  defp recipe_stream recipe1, recipe2 do
    recipes = <<recipe1, recipe2>>
    acc = {recipes, {0, 1}, [recipe1, recipe2]}
    Stream.unfold(acc, &get_next_recipe/1)
  end

  defp get_next_recipe acc do
    case acc do
      {recipes, cur, [h | t]} ->
	{h, {recipes, cur, t}}
      {recipes, cur, []} ->
	get_next_recipe(build_more_recipes(recipes, cur))
    end
  end

  defp build_more_recipes recipes, {cur1, cur2} do
    next = :binary.at(recipes, cur1) + :binary.at(recipes, cur2)
    new_recipes = Enum.map(Integer.to_charlist(next), &(&1 - ?0))
    recipes = <<recipes::binary, :erlang.list_to_binary(new_recipes)::binary>>
    size = byte_size recipes
    cur1 = rem(cur1 + 1 + :binary.at(recipes, cur1), size)
    cur2 = rem(cur2 + 1 + :binary.at(recipes, cur2), size)
    {recipes, {cur1, cur2}, new_recipes}
  end
end
