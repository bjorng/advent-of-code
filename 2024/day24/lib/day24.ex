defmodule Day24 do
  import Bitwise

  def part1(input) do
    {values, gates} = parse(input)

    gates = Enum.map(gates, fn {dst, {op, src1, src2}} ->
      op = case op do
             :"AND" -> &band/2
             :"OR" -> &bor/2
             :"XOR" -> &bxor/2
           end
      {dst, {op, src1, src2}}
    end)

    values = Map.new(values)

    outputs(gates, values, &next_item_part1/1)
    |> Enum.map(fn pair ->
      case pair do
        {{:z, n}, 1} -> 1 <<< n
        _ -> 0
      end
    end)
    |> Enum.sum
  end

  defp next_item_part1({gates, values}) do
    Enum.flat_map_reduce(gates, values, fn gate, values ->
      {dst, {op, src1, src2}} = gate
      case values do
        %{^src1 => val1, ^src2 => val2} ->
          {[], Map.put(values, dst, op.(val1, val2))}
        %{} ->
          {[gate], values}
      end
    end)
  end

  def part2(input, _num_pairs \\ 4) do
    {values, gates} = parse(input)

    gates = Map.new(gates)

    values = values
    |> Enum.map(fn {name, _} ->
      {name, name}
    end)
    |> Map.new

    # Try crossing each possible pair of vertices. Repeat until
    # all four pairs are found.
    Stream.iterate({gates, values, []}, &swap/1)
    |> Stream.drop_while(fn {_, _, swaps} -> length(swaps) < 8 end)
    |> Enum.take(1)
    |> then(fn [{_, _, swapped}] -> swapped end)
    |> Enum.map(&wire_to_atom/1)
    |> Enum.sort
    |> Enum.join(",")
  end

  defp next_item_part2({gates, values}) do
    Enum.flat_map_reduce(gates, values, fn gate, values ->
      {dst, {op, src1, src2}} = gate
      case values do
        %{^src1 => val1, ^src2 => val2} ->
          {[], Map.put(values, dst, {op, [val1, val2]})}
        %{} ->
          {[gate], values}
      end
    end)
    |> then(fn {new_gates, values} ->
      if gates === new_gates do
        throw(:loop)
      end
      {new_gates, values}
    end)
  end

  defp swap({gates, values, swaps}) do
    {:z, first_miswired} = output = find_first_miswired(gates, values)
    IO.puts "first miswired output: #{wire_to_atom(output)}"

    wires = Enum.flat_map(gates, fn gate ->
      case gate do
        {same, same} -> []
        {name, _} -> [name]
      end
    end) -- [output]

    # Try swapping the `z` output with all other outputs. For my
    # input, that succeeded for three of the miswirings.
    try_wires(output, wires, gates, values, first_miswired)
    |> then(fn result ->
      # So that didn't work. Now try all pairs of wires.
      result || try_wires(wires, gates, values, first_miswired)
    end)
    |> then(fn {wires, gates} ->
      {gates, values, wires ++ swaps}
    end)
  end

  defp try_wires([], _gates, _values, _first_miswired), do: nil
  defp try_wires([wire1|wires], gates, values, first_miswired) do
    try_wires(wire1, wires, gates, values, first_miswired) ||
      try_wires(wires, gates, values, first_miswired)
  end

  defp try_wires(wire1, wires, gates, values, first_miswired) do
    Enum.find_value(wires, fn wire2 ->
      case try_wire_pair(wire1, wire2, gates, values) do
        {{:z, output}, gates} when output > first_miswired ->
          # This fixed the miswiring.
          {[wire1, wire2], gates}
        _ ->
          false
      end
    end)
  end

  defp try_wire_pair(wire1, wire2, gates, values) do
    %{^wire1 => gate1, ^wire2 => gate2} = gates
    gates = %{gates | wire1 => gate2, wire2 => gate1}
    try do
      find_first_miswired(gates, values)
    catch
      :loop ->
        nil
    else
      nil ->
        nil
      first_miswired ->
        {first_miswired, gates}
    end
  end

  defp find_first_miswired(gates, values) do
    outputs(gates, values, &next_item_part2/1)
    |> Enum.map(fn {name, expr} ->
      {name, normalize_gate(expr)}
    end)
    |> Enum.sort
    |> Enum.find(&miswired?/1)
    |> elem(0)
  end

  # Test whether a specific `z` output is miswired.
  defp miswired?({{:z, bit}, expr}) do
    do_miswired_xor(expr, bit)
  end

  defp do_miswired_xor({:"XOR", args}, bit) do
    expected = make_expected(bit)
    case args do
      ^expected when bit === 0 ->
        false
      [{:"AND", _}=arg1, {:"XOR", ^expected}] when bit === 1 ->
        do_miswired_and(arg1, bit)
      [{:"OR", _}=arg1, {:"XOR", ^expected}] ->
        do_miswired_or(arg1, bit)
      _ ->
        true
    end
  end
  defp do_miswired_xor(_expr, _bit), do: true

  defp do_miswired_or({:"OR", expr}, bit) do
    expected = make_expected(bit - 1)
    case expr do
      [arg1, {:"AND", ^expected}] ->
        do_miswired_and(arg1, bit)
      _ ->
        true
    end
  end
  defp do_miswired_or(_expr, _bit), do: true

  defp do_miswired_and({:"AND", args}, bit) do
    expected = make_expected(bit - 1)
    case args do
      [{:x, 0}, {:y, 0}] when bit === 1 ->
        false
      [{:x, 1}, {:y, 1}] when bit === 2 ->
        false
      [{:"AND", [{:x, 0}, {:y, 0}]},
          {:"XOR", [{:x, 1}, {:y, 1}]}] when bit === 2 ->
        false
      [{:"OR", _}=arg1, {:"XOR", ^expected}] ->
        do_miswired_or(arg1, bit - 1)
      _ ->
        true
    end
  end
  defp do_miswired_and(_expr, _bit), do: true

  defp make_expected(bit), do: [{:x, bit}, {:y, bit}]

  defp normalize_gate(expr) do
    case expr do
      {prefix, n} when is_integer(n) ->
        {prefix, n}
      {op, args} when is_list(args) ->
        # Sort the arguments to simplify matching. We depend on the
        # Erlang term order, specifically that all operators compare
        # less than the letters `x` and `y`.
        Enum.map(args, &normalize_gate/1)
        |> Enum.sort
        |> then(&{op, &1})
    end
  end

  defp outputs(gates, values, next_item) do
    Stream.iterate({gates, values}, next_item)
    |> Stream.drop_while(fn {gates, _} -> gates !== [] end)
    |> Enum.take(1)
    |> then(fn [{_, values}] -> values end)
    |> Enum.filter(fn {wire, _} ->
      match?({:z, _}, wire)
    end)
  end

  defp wire_to_atom(wire) do
    case wire do
      {:z, n} ->
        n
        |> Integer.to_string
        |> String.pad_leading(3, ["z", "0"])
        |> String.to_atom
      _ ->
        wire
    end
  end

  defp parse(input) do
    [values, gates] = String.split(input, "\n\n", trim: true)
    {String.split(values, "\n", trim: true)
    |> Enum.map(fn value ->
       [name, value] = String.split(value, ": ")
       {parse_wire(name), String.to_integer(value)}
     end),
     String.split(gates, "\n", trim: true)
     |> Enum.map(fn gate ->
       [a, op, b, "->", c] = String.split(gate, " ")
       {parse_wire(c),
        {String.to_atom(op), parse_wire(a), parse_wire(b)}}
     end)}
  end

  defp parse_wire(name) do
    case name do
      <<prefix, digits::binary>> when prefix in [?x, ?y, ?z] ->
        {List.to_atom([prefix]), String.to_integer(digits)}
      _ ->
        String.to_atom(name)
    end
  end
end
