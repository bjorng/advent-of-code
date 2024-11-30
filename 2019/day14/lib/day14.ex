defmodule Day14 do
  @trillion 1_000_000_000_000

  def part1(input) do
    cookbook = parse_input(input)
    ores(1, cookbook)
  end

  def part2(input) do
    cookbook = parse_input(input)
    max = ores(1, cookbook) * @trillion
    bin_search(1, max, cookbook)
  end

  defp bin_search(min, max, _cookbook) when min > max, do: max
  defp bin_search(min, max, cookbook) do
    fuel = div(min + max, 2)
    ores_quant = ores(fuel, cookbook)
    case ores_quant <= @trillion do
      true ->
	bin_search(fuel + 1, max, cookbook)
      false ->
	bin_search(min, fuel - 1, cookbook)
    end
  end

  defp ores(fuel_quant, cookbook) do
    {_store, ores} = produce([{"FUEL", fuel_quant}], cookbook, %{}, 0)
    ores
  end

  defp produce([{"ORE", need_quant} | need], cookbook, store, ores) do
    produce(need, cookbook, store, ores + need_quant)
  end
  defp produce([{name, need_quant} | need], cookbook, store, ores) do
    {store, need_quant} = take_from_store(store, name, need_quant)
    {prod_quant, ingredients} = Map.fetch!(cookbook, name)
    prod_units = div(need_quant + prod_quant - 1, prod_quant)
    ingredients = Enum.map(ingredients, fn {name, q} -> {name, q * prod_units} end)
    {store, ores} = produce(ingredients, cookbook, store, ores)
    actual_quant = prod_units * prod_quant
    store = update_store(store, name, actual_quant - need_quant)
    produce(need, cookbook, store, ores)
  end
  defp produce([], _, store, ores), do: {store, ores}

  defp take_from_store(store, name, quant) do
    case store do
      %{^name => stored_quant} ->
	taken = min(quant, stored_quant)
        {Map.put(store, name, stored_quant - taken), quant - taken}
      %{} ->
	{store, quant}
    end
  end

  defp update_store(store, name, quant) do
    Map.update(store, name, quant, & &1 + quant)
  end

  defp parse_input(input) do
    input
    |> Enum.map(&split_line/1)
    |> Map.new
  end

  defp split_line(line) do
    [needed, produces] = String.split(line, " => ")
    needed = String.split(needed, ", ")
    needed = Enum.map(needed, &parse_comp/1)
    {name, quant} = parse_comp(produces)
    {name, {quant, needed}}
  end

  defp parse_comp(comp) do
    {int, " " <> name} = Integer.parse(comp)
    {name, int}
  end
end
