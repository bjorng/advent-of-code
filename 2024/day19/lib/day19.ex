defmodule Day19 do
  def part1(input) do
    solve(input, false)
  end

  def part2(input) do
    solve(input, true)
  end

  defp solve(input, all) do
    {patterns, designs} = parse(input)
    [{:top, patterns}] = preprocess_patterns(%{top: patterns})
    designs
    |> Enum.map(fn design ->
      memo = %{"" => 1}
      count(design, patterns, all, memo)
      |> elem(0)
    end)
    |> Enum.sum
  end

  defp count(design, patterns, all, memo) do
    case memo do
      %{^design => ways} ->
        {ways, memo}
      %{} ->
        match_one(design, patterns)
        |> Enum.flat_map_reduce(memo, fn size, memo when is_integer(size) ->
          rest = :binary.part(design, size, byte_size(design) - size)
          case count(rest, patterns, all, memo) do
            {0, memo} -> {[], memo}
            {ways, memo} -> {[ways], memo}
          end
        end)
        |> then(fn {possible, memo} ->
          ways = cond do
            possible === [] ->
              0
            all ->
              Enum.sum(possible)
            true ->
              1
          end
          memo = Map.put(memo, design, ways)
          {ways, memo}
        end)
    end
  end

  defp match_one(design, pat) do
    match_one(design, pat, 0)
  end

  defp match_one(design, pat, n) do
    case design do
      <<first::binary-size(1), rest::binary>> ->
        case Enum.find_value(pat, fn {letter, pat} ->
              if first === letter, do: pat, else: nil
            end) do
          nil ->
            nil_match(pat, n)
          next_pat ->
            nil_match(pat, n) ++ match_one(rest, next_pat, n + 1)
        end
      <<>> ->
        nil_match(pat, n)
    end
  end

  defp nil_match(pat, n) do
    case pat do
      [{nil, _}|_] -> [n]
      _ -> []
    end
  end

  defp preprocess_patterns(groups) do
    Enum.map(groups, fn {key, group} ->
      Enum.group_by(group, fn pat ->
        if pat === "", do: nil, else: :binary.part(pat, 0, 1)
      end)
      |> Enum.map(fn {letter, patterns} ->
        Enum.map(patterns, fn pat ->
          if pat === "" do
            pat
          else
            :binary.part(pat, 1, byte_size(pat) - 1)
          end
        end)
        |> then(fn patterns ->
          {letter, patterns}
        end)
      end)
      |> then(fn group ->
      case group do
        nil: [""] ->
          {key, nil: []}
        _ ->
          {key, preprocess_patterns(group)}
      end
        end)
    end)
  end

  defp parse(input) do
    [patterns, designs] = String.split(input, "\n\n", trim: true)
    patterns = String.split(patterns, ", ", trim: true)
    designs = String.split(designs, "\n", trim: true)
    {patterns, designs}
  end
end
