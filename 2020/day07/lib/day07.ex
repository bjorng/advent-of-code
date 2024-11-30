defmodule Day07 do
  def part1(input) do
    Parser.parse(input)
    |> find_containers("shiny gold", MapSet.new())
    |> Enum.count
  end

  def part2(input) do
    rules = Parser.parse(input)
    |> Map.new
    count_bags(rules, Map.get(rules, "shiny gold"), 0)
  end

  defp find_containers(rules, bag, found) do
    Enum.reduce(rules, found, fn {container, bags}, acc ->
      case List.keymember?(bags, bag, 1) do
        true ->
          find_containers(rules, container, MapSet.put(acc, container))
        false ->
          acc
      end
    end)
  end

  defp count_bags(_rules, [], sum), do: sum
  defp count_bags(rules, [{amount, bag} | bags], sum) do
    contains = Map.get(rules, bag)
    sum = sum + amount + amount * count_bags(rules, contains, 0)
    count_bags(rules, bags, sum)
  end
end

defmodule Parser do
  import NimbleParsec

  space = ignore(string(" "))
  comma = ignore(string(", "))
  word = ascii_string([?a..?z], min: 1)

  defp pack_bag(adjectives) do
    Enum.join(adjectives, " ")
  end

  defcombinatorp :words, word
  |> repeat(optional(space) |> parsec(:words))

  one_bag = times(concat(word, space), 2)
  |> ignore(string("bag"))
  |> ignore(optional(string("s")))
  |> reduce({:pack_bag, []})

  amount_bag = integer(min: 1)
  |> ignore(space)
  |> concat(one_bag)
  |> reduce({List, :to_tuple, []})

  defcombinatorp :bag_list, amount_bag
  |> repeat(comma |> parsec(:bag_list))

  no_other_bags = ignore(string("no other bags"))

  containing = choice([parsec(:bag_list), no_other_bags])
  |> wrap

  defparsecp :main, one_bag
  |> ignore(string(" contain "))
  |> concat(containing)
  |> ignore(string("."))
  |> eos

  def parse(input) do
    Enum.map(input, fn(line) ->
      {:ok, res, _, _, _, _} = main(line)
      List.to_tuple(res)
    end)
  end
end
