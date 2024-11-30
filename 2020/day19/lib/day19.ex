defmodule Day19 do
  def part1(input) do
    solve(input)
  end

  def part2(input) do
    input = patch_rules(input)
    solve(input)
  end

  defp solve(input) do
    {rules, messages} = Parser.parse(input)
    rules = Map.new(rules)
    Enum.count(messages, fn message -> is_valid_message(message, rules) end)
  end

  defp patch_rules(input) do
    Enum.map(input, fn line ->
      line = Regex.replace(~r/^8:.*/, line, "8: 42 | 42 8")
      Regex.replace(~r/^11:.*/, line, "11: 42 31 | 42 11 31")
    end)
  end

  defp is_valid_message(message, rules) do
    chars = String.to_charlist(message)
    case match_rule(0, chars, rules) do
      {:multiple, [[] | _]} -> true
      [] -> true
      _ -> false
    end
  end

  defp match_rule(rule_num, chars, rules) when is_integer(rule_num) do
    case Map.get(rules, rule_num) do
      [{:literal, literal}] ->
        case chars do
          [^literal | chars] ->
            chars
          {:multiple, closure} ->
            Enum.reduce(closure, [],
              fn
                [^literal | chars], acc -> [chars | acc]
                _, acc -> acc
              end)
              |> build_multiple
          other when is_list(other) ->
            nil
        end
      rule_groups when is_list(rule_groups) ->
        match_groups(rule_groups, chars, rules)
    end
  end

  defp match_groups(groups, chars, rules) do
    list = Enum.map(groups, fn group ->
      match_seq(group, chars, rules)
    end)
    |> Enum.reject(&is_nil/1)
    build_multiple(list)
  end

  defp match_seq([], chars, _rules), do: chars
  defp match_seq([rule_num | rule_numbers], chars, rules) when is_integer(rule_num) do
    case match_rule(rule_num, chars, rules) do
      nil -> nil
      chars -> match_seq(rule_numbers, chars, rules)
    end
  end

  defp build_multiple(list) do
    list = Enum.reduce(list, [], fn elem, acc ->
      case elem do
        {:multiple, elems} -> elems ++ acc
        _ -> [elem | acc]
      end
    end)
    |> Enum.sort
    |> Enum.uniq
    case list do
      [] -> nil
      [chars] -> chars
      _ -> {:multiple, list}
    end
  end
end

defmodule Parser do
  import NimbleParsec
  space = ignore(string(" "))

  defp pack_literal([literal]) do
    {:literal, literal}
  end

  defp pack_rules(elems) do
    List.flatten(elems)
  end

  defp pack_rule_def([number | rule_groups]) do
    {number, rule_groups}
  end

  defcombinatorp :rules, integer(min: 1)
  |> repeat(space |> parsec(:rules))
  |> reduce({:pack_rules, []})

  rule_line = parsec(:rules)
  |> optional(ignore(string(" | ")) |> parsec(:rules))

  literal_string = ignore(string("\""))
  |> ascii_char([?a..?b])
  |> ignore(string("\""))
  |> reduce({:pack_literal, []})

  rule_def = integer(min: 1)
  |> ignore(string(": "))
  |> choice([literal_string, rule_line])
  |> reduce({:pack_rule_def, []})

  message = ascii_string([?a..?b], min: 1)

  defparsecp :main, choice([rule_def, message]) |> eos()

  def parse(input) do
    Enum.map(input, fn(line) ->
      {:ok, [res], _, _, _, _} = main(line)
      res
    end)
    |> Enum.chunk_by(&is_tuple/1)
    |> List.to_tuple
  end
end
