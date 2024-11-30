defmodule Day12 do
  def part1 lines do
    [initial, "" | rules] = lines
    pots = parse_state(initial)
    rules = parse_rules(rules)
    Enum.reduce(1..20, pots, fn _, pots -> run_rules(rules, pots) end)
    |> Enum.to_list
    |> Enum.sum
  end

  def part2 lines do
    [initial, "" | rules] = lines
    pots = parse_state(initial)
    rules = parse_rules(rules)
    run(1, 50000000000, pots, rules)
  end

  def run(gen, last_gen, old_pots, rules) do
    new_pots = run_rules rules, old_pots
    case shifted_pots(old_pots, new_pots) do
      {:yes, amount} ->
	left = last_gen - gen
	Enum.map(new_pots, &(&1 + amount * left))
	|> Enum.sum
      :no ->
	run gen + 1, last_gen, new_pots, rules
    end
  end

  def shifted_pots old_pots, new_pots do
    old_pots = Enum.sort(MapSet.to_list(old_pots))
    new_pots = Enum.sort(MapSet.to_list(new_pots))
    Enum.zip(old_pots, new_pots)
    |> Enum.map(fn {pot1, pot2} -> pot2 - pot1 end)
    |> Enum.sort
    |> Enum.dedup
    |> (fn list ->
      case list do
	[const] -> {:yes, const}
	_ -> :no
      end
    end).()
  end

  def run_rules rules, old_pots do
    #print_pots old_pots
    {min, max} = Enum.min_max(MapSet.to_list(old_pots))
    new_pots = MapSet.new()
    {_, new_pots} = Enum.reduce(min-3..max+3, {old_pots, new_pots},
      fn pot, {_old_pots, _new_pots} = acc ->
	Enum.reduce_while(rules, acc,
	  fn rule, {old_pots, new_pots} ->
	    {pattern, result} = rule
	    case match_pattern?(pattern, pot, old_pots) do
	      true ->
		case result do
		  :empty ->
		    {:halt, {old_pots, MapSet.delete(new_pots, pot)}}
		  :plant ->
		    {:halt, {old_pots, MapSet.put(new_pots, pot)}}
		end
	      false ->
	      {:cont, {old_pots, new_pots}}
	    end
	  end)
      end)
    new_pots
  end

  def print_pots pots do
    {min, max} = Enum.min_max(MapSet.to_list(pots))
    IO.puts Enum.map(min-3..max+3, fn pot ->
      case pot in pots do
	true -> ?\#
	false -> ?.
      end
    end)
  end

  def match_pattern? pattern, pot, old_pots do
    Enum.all?(pattern, fn {state, pos} ->
      pos = pot + pos
      case pos in old_pots do
	true ->
	  state == :plant
	false ->
	  state == :empty
      end
    end)
  end

  def parse_rules lines do
    Enum.map(lines, &parse_rule/1)
  end

  def parse_rule <<p1,p2,p3,p4,p5," => ",result>> do
    for p <- [p1, p2, p3, p4, p5, result]
      do case p do
	   ?\# -> :plant
	   ?. -> :empty
	 end
    end
    |> Enum.zip(-2..3)
    |> (fn [p1, p2, p3, p4, p5, {result, _}] ->
      {[p1, p2, p3, p4, p5], result}
    end).()
  end


  @doc """
  Parse initial state.

  ## Examples

      iex> Enum.sort(Day12.parse_state("initial state: #..##...."))
      [0, 3, 4]

  """
  def parse_state line do
    <<"initial state: ",rest::binary>> = line
    parse_state_1(String.to_charlist(rest), 0, MapSet.new())
  end

  def parse_state_1([?\# | tail], n, set) do
    parse_state_1(tail, n + 1, MapSet.put(set, n))
  end

  def parse_state_1([?. | tail], n, set) do
    parse_state_1(tail, n + 1, set)
  end

  def parse_state_1([], _n, set), do: set

end
