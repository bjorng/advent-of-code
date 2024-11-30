defmodule Day11 do
  use Bitwise

  def part1(input) do
    Parser.parse(input)
    |> solve
  end

  def part2(input) do
    Parser.parse(input)
    |> add_to_first_floor
    |> solve
  end

  defp add_to_first_floor([{1, things} | rest]) do
    [{1, [{:generator, :dilithium},
          {:generator, :elerium},
          {:microchip, :dilithium},
          {:microchip, :elerium} | things]} | rest]
  end

  defp solve(input) do
    state = input
    |> convert_to_bitmap
    |> Map.new
    |> Map.put(:current_floor, 1)

    bfs([state], 0, MapSet.new(state))
  end

  defp convert_to_bitmap(contents) do
    bitmap = contents
    |> Enum.flat_map(fn {_, list} ->
      for {_, type} <- list, do: type
    end)
    |> Enum.uniq
    |> Enum.with_index
    |> Map.new

    Enum.map(contents, fn {floor, list} ->
      generators = things_to_bitmask(list, :generator, bitmap)
      microchips = things_to_bitmask(list, :microchip, bitmap)
      {floor, {generators, microchips}}
    end)
  end

  defp things_to_bitmask(list, tag, bitmap) do
    Enum.reduce(list, 0, fn thing, acc ->
      case thing do
        {^tag, type} ->
          acc ||| (1 <<< Map.fetch!(bitmap, type))
        _ ->
          acc
      end
    end)
  end

  defp bfs([], moves, _seen), do: {:failed, moves}
  defp bfs(states, moves, seen) do
    case Enum.any?(states, &is_done?/1) do
      true ->
        moves
      false ->
        {states, seen} = update_states(states, seen, [])
#        IO.inspect {moves, length(states)}
        bfs(states, moves + 1, seen)
    end
  end

  defp is_done?(state) do
    case state do
      %{1 => {0,0}, 2 => {0,0}, 3 => {0,0}} -> true
      %{} -> false
    end
  end

  defp update_states([], seen, acc), do: {acc, seen}
  defp update_states([state | states], seen, acc) do
    floor = Map.fetch!(state, :current_floor)
    things_here = Map.fetch!(state, floor)
    movables = combinations(things_here)
    |> Enum.filter(fn things_moved ->
      move_possible?(remove(things_here, things_moved))
    end)

    moved = move_to(floor, floor + 1, movables, state, [])
    moved = move_to(floor, floor - 1, movables, state, moved)

    new_states = moved
    |> Enum.map(&canonical_state/1)
    |> Enum.reject(&MapSet.member?(seen, &1))

    seen = Enum.reduce(new_states, seen, &MapSet.put(&2, &1))
    update_states(states, seen, new_states ++ acc)
  end

  defp canonical_state(state) do
    mapping = 1..4
    |> Enum.flat_map(fn floor ->
      {gen, chip} = Map.fetch!(state, floor)
      bit_numbers(gen ||| chip, 0, [])
    end)
    |> Enum.uniq
    |> Enum.with_index
    |> Map.new

    1..4
    |> Enum.reduce(state, fn floor, state ->
      {gen, chip} = Map.fetch!(state, floor)
      gen = translate_bits(gen, mapping, 0, 0)
      chip = translate_bits(chip, mapping, 0, 0)
      Map.replace(state, floor, {gen, chip})
    end)
  end

  defp bit_numbers(0, _, acc), do: acc
  defp bit_numbers(bits, n, acc) do
    case bits &&& 1 do
      0 -> bit_numbers(bits >>> 1, n + 1, acc)
      1 -> bit_numbers(bits >>> 1, n + 1, [n | acc])
    end
  end

  defp translate_bits(0, _, _, acc), do: acc
  defp translate_bits(bits, mapping, n, acc) do
    case bits &&& 1 do
      0 -> translate_bits(bits >>> 1, mapping, n + 1, acc)
      1 -> translate_bits(bits >>> 1, mapping, n + 1, acc ||| (1 <<< Map.fetch!(mapping, n)))
    end
  end

  defp remove({gens, chips}, {gens1, chips1}) do
    {gens &&& bnot(gens1), chips &&& bnot(chips1)}
  end

  defp add({gens, chips}, {gens1, chips1}) do
    {gens ||| gens1, chips ||| chips1}
  end

  defp move_to(from_floor, to_floor, combinations, state, acc) do
    case state do
      %{^from_floor => things_here,
        ^to_floor => already_there} ->
        Enum.reduce(combinations, acc, fn moved_things, acc ->
          all_things = add(moved_things, already_there)
          case move_possible?(all_things) do
            false ->
              acc
            true ->
              state = %{state | from_floor => remove(things_here, moved_things),
                        to_floor => all_things,
                        :current_floor => to_floor}
              [state | acc]
          end
        end)
      %{} ->
        acc
    end
  end

  defp move_possible?({generators, microchips}) do
    generators === 0 or microchips === 0 or (generators &&& microchips) === microchips
  end

  defp combinations({generators, microchips}) do
    for gen <- bit_combinations(generators, 0),
      chip <- bit_combinations(microchips, 0),
      (count_ones(gen) + count_ones(chip) in 1..2) do
        {gen, chip}
    end
  end

  defp bit_combinations(0, _), do: [0]
  defp bit_combinations(mask, n) do
    case (mask >>> n) &&& 1 do
      0 ->
        bit_combinations(mask, n + 1)
      1 ->
        bit = 1 <<< n
        mask = mask &&& bnot bit
        [bit | Enum.map(bits(mask, n + 1), fn other_bits ->
            bit ||| other_bits
          end)] ++ bit_combinations(mask, n + 1)
    end
  end

  defp bits(0, _), do: []
  defp bits(mask, n) do
    case (mask >>> n) &&& 1 do
      0 ->
        bits(mask, n + 1)
      1 ->
        bit = 1 <<< n
        mask = mask &&& bnot bit
        [1 <<< n | bits(mask, n + 1)]
    end
  end

  def count_ones(n), do: count_ones(n, 0)

  def count_ones(0, count), do: count
  def count_ones(n, count), do: count_ones(n &&& (n - 1), count + 1)
end

defmodule Parser do
  import NimbleParsec

  defp map_number([word]) do
    map = ~w(first second third fourth)
    |> Enum.with_index(1)
    |> Map.new
    Map.fetch!(map, word)
  end

  defp to_atom([word]), do: String.to_atom(word)

  defp pack_arrangement([floor | contents]) do
    {floor, Enum.sort(contents)}
  end

  blank = ignore(optional(ascii_char([?\s])))

  a_an = ignore(string("a") |> optional(string("n")))

  atom = ascii_string([?a..?z], min: 1)
  |> reduce({:to_atom, []})

  generator = atom
  |> concat(blank)
  |> ignore(string("generator"))
  |> unwrap_and_tag(:generator)

  microchip = atom
  |> ignore(string("-compatible microchip"))
  |> unwrap_and_tag(:microchip)

  nothing = ignore(string("nothing relevant"))

  thing = optional(a_an)
  |> concat(blank)
  |> choice([microchip, generator, nothing])

  conjunction = ignore(optional(string(",")) |> optional(string(" and")))

  defcombinatorp :things,
    thing
    |> choice([conjunction |> concat(blank) |> parsec(:things),
              ignore(string("."))])

  ordinal_number = ascii_string([?a..?z], min: 1)
  |> reduce({:map_number, []})

  floor = ignore(string("The "))
  |> concat(ordinal_number)
  |> ignore(string(" floor"))

  defparsec :arrangement, floor
  |> ignore(string(" contains "))
  |> parsec(:things)
  |> reduce({:pack_arrangement, []})
  |> eos

  def parse(input) do
    Enum.map(input, fn line ->
      {:ok, [result], "", _, _, _} = arrangement(line)
      result
    end)
  end
end
