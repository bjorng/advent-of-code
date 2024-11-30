defmodule Day08 do
  def part1(input) do
    parse(input)
    |> Enum.flat_map(&(elem(&1, 1)))
    |> Enum.filter(fn output ->
      byte_size(output) in [2, 3, 4, 7]
    end)
    |> Enum.count
  end

  def part2(input) do
    input = parse(input)

    mappings = Enum.map(?a..?g, fn wire ->
      {to_string([wire]), Enum.map(?a..?g, &(to_string([&1])))}
    end)
    |> Map.new

    {segment_map, digit_map} = wirings()

    Enum.map(input, fn display ->
      solve(display, mappings, segment_map, digit_map)
    end)
    |> Enum.sum
  end

  defp solve({digits, output}, mappings, segment_map, digit_map) do
    translation =
      Enum.reduce(digits, mappings, fn wires, acc ->
        solve(wires, acc, segment_map)
      end)
      |> Enum.map(fn {from, [to]} -> {from, to} end)
      |> Map.new

    Enum.map(output, &(translate_output(&1, translation, digit_map)))
    |> Enum.reduce(0, &(&2 * 10 + &1))
  end

  defp solve(wires, mappings, segment_map) do
    possibilities = Map.fetch!(segment_map, byte_size(wires))

    possible = possibilities
    |> Enum.concat
    |> Enum.sort
    |> Enum.dedup

    wires = String.codepoints(wires)
    all = ~w(a b c d e f g)
    other_wires = all -- wires

    not_possible = Enum.reduce(possibilities, &:ordsets.intersection/2)

    mappings
    |> eliminate(wires, &(:ordsets.intersection(&1, possible)))
    |> eliminate(other_wires, &(&1 -- not_possible))
  end

  defp eliminate(mappings, wires, f) do
    Enum.reduce(wires, mappings, fn wire, acc ->
      mappings = Map.update!(acc, wire, f)
      case mappings do
        %{^wire => [target]} ->
          all = ~w(a b c d e f g)
          other_wires = all -- [wire]
          Enum.reduce(other_wires, mappings, fn wire, acc ->
            Map.update!(acc, wire, &(&1 -- [target]))
          end)
        %{} ->
          mappings
      end
    end)
  end

  defp translate_output(wires, translation, digit_map) do
    new_wires = String.codepoints(wires)
    |> Enum.map(fn wire -> Map.fetch!(translation, wire) end)
    |> Enum.sort

    Map.fetch!(digit_map, new_wires)
  end

  defp wirings() do
    ws = [{2, [{1, ~w(c f)}]},
          {3, [{7, ~w(a c f)}]},
          {4, [{4, ~w(b c d f)}]},
          {5, [{2, ~w(a c d e g)},
               {3, ~w(a c d f g)},
               {5, ~w(a b d f g)}]},
          {6, [{0, ~w(a b c e f g)},
               {6, ~w(a b d e f g)},
               {9, ~w(a b c d f g)}]},
          {7, [{8, ~w(a b c d e f g)}]}]

    segment_map = Enum.map(ws, fn {n, list} ->
      {n, Enum.map(list, &(elem(&1, 1)))}
    end)
    |> Map.new

    digit_map = Enum.flat_map(ws, &(elem(&1, 1)))
    |> Enum.map(fn {digit, segments} -> {segments, digit} end)
    |> Map.new

    {segment_map, digit_map}
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      [wires, output] = String.split(line, " | ")
      {String.split(wires), String.split(output)}
    end)
  end
end
