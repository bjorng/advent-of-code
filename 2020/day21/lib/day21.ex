defmodule Day21 do
  def part1(input) do
    input = Parser.parse(input)

    all_ingredients = input
    |> Enum.map(fn {ingredients, _} ->
      MapSet.new(ingredients)
    end)
    |> Enum.reduce(&MapSet.union/2)

    allergic_ingredients = group_allergic_ingredients(input)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(&MapSet.union/2)

    non_allergic = MapSet.difference(all_ingredients, allergic_ingredients)

    Enum.flat_map(input, fn {ingredients, _} ->
      Enum.filter(ingredients, fn ingredient ->
        MapSet.member?(non_allergic, ingredient)
      end)
    end)
    |> Enum.count
  end

  def part2(input) do
    allergic_ingredients = Parser.parse(input)
    |> group_allergic_ingredients

    find_allergic_ingredients(allergic_ingredients, [])
    |> Enum.sort
    |> Enum.map(&elem(&1, 1))
    |> Enum.join(",")
  end

  defp group_allergic_ingredients(input) do
    input
    |> Enum.flat_map(fn {ingredients, allergens} ->
      Enum.map(allergens, fn allergen ->
        {allergen, MapSet.new(ingredients)}
      end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {allergen, ingredient_lists} ->
      common =
        Enum.reduce(ingredient_lists, fn ingredients, acc ->
          MapSet.intersection(acc, MapSet.new(ingredients))
        end)
        {allergen, common}
    end)
  end

  defp find_allergic_ingredients(list, acc) do
    case Enum.sort_by(list, &MapSet.size(elem(&1, 1))) do
      [{name, set} | rest] ->
        [ingredient] = MapSet.to_list(set)
        rest = Enum.map(rest, fn {name, ingredients} ->
          {name, MapSet.delete(ingredients, ingredient)}
        end)
        find_allergic_ingredients(rest, [{name, ingredient} | acc])
      [] ->
        acc
    end
  end

end

defmodule Parser do
  import NimbleParsec

  space = ignore(string(" "))
  comma = ignore(string(", "))
  word = ascii_string([?a..?z], min: 1)

  defcombinatorp :comma_words, word
  |> repeat(comma |> parsec(:comma_words))

  defcombinatorp :words, word
  |> repeat(optional(space) |> parsec(:words))

  ingredients = parsec(:words) |> wrap

  contains = ignore(string("(contains "))
  |> parsec(:comma_words)
  |> ignore(string(")"))
  |> wrap

  defparsecp :main, ingredients
  |> optional(space)
  |> concat(contains)
  |> eos

  def parse(input) do
    Enum.map(input, fn(line) ->
      {:ok, res, _, _, _, _} = main(line)
      List.to_tuple(res)
    end)
  end
end
