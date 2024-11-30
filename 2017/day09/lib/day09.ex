defmodule Day09 do
  def part1(string) when is_binary(string) do
    groups = parse(string)
    score(groups, 1, 0)
  end

  def part2(string) when is_binary(string) do
    groups = parse(string)
    count_garbage(groups, 0)
  end

  defp count_garbage(groups, count) do
    case groups do
      [{:garbage, garbage} | rest] ->
	count_garbage(rest, length(garbage) + count)
      [{:group, group} | rest] ->
	count_garbage(group, count_garbage(rest, count))
      [] ->
	count
    end
  end

  defp score([{:group, groups} | rest], level_score, total_score) do
    total_score = score(rest, level_score, total_score + level_score)
    score(groups, level_score + 1, total_score)
  end

  defp score([{:garbage, _} | rest], level_score, total_score) do
    score(rest, level_score, total_score)
  end

  defp score([], _, total_score), do: total_score

  defp parse(string) do
    {groups, <<>>} = parse_group(string, [])
    groups
  end

  defp parse_group(string, acc) do
    case string do
      "{" <> rest ->
	{group, rest} = parse_group(rest, [])
	"}" <> rest = rest
	parse_comma_or_end(rest, [{:group, group} | acc])
      "<" <> rest ->
	{garbage, rest} = parse_garbage(rest, [])
	parse_comma_or_end(rest, [{:garbage, garbage} | acc])
      rest ->
	{Enum.reverse(acc), rest}
    end
  end

  defp parse_comma_or_end(string, acc) do
    case string do
      "," <> rest ->
	parse_group(rest, acc)
      "" <> rest ->
	{Enum.reverse(acc), rest}
    end
  end

  defp parse_garbage(string, acc) do
    case string do
      "!" <> <<_char, rest::binary>> ->
	parse_garbage(rest, acc)
      ">" <> rest ->
	{Enum.reverse(acc), rest}
      <<char, rest::binary>> ->
	parse_garbage(rest, [char | acc])
    end
  end
end
