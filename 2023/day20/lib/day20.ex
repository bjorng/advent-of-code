defmodule Day20 do
  def part1(input) do
    input = parse(input)

    modules = prepare_modules(input)

    1..1000
    |> Enum.map_reduce(modules, fn _, modules ->
      q = :queue.from_list([{:broadcaster, :broadcaster, false}])
      pulse(q, modules)
    end)
    |> then(&elem(&1, 0))
    |> Enum.reduce(fn {low, high}, {lowacc, highacc} ->
      {lowacc + low, highacc + high}
    end)
    |> then(fn {low, high} -> low * high end)
  end

  def part2(input) do
    input = parse(input)

    # It so happens that the input can be cleanly partitioned into
    # separate input lists, where the broadcaster in each list has a
    # single destination. Those lists can then be solved separately,
    # and the total cycle length can be be obtained by multiplying the
    # cycles for each list. (At least for my input, there was no need
    # to find any least common multiples.)

    partition(input)
    |> Enum.map(&solve_part2/1)
    |> Enum.product
  end

  defp partition(input) do
    all = Enum.map(input, fn {_, name, _} = module ->
      {name, module}
    end)
    |> Map.new

    {_, _, list} = Map.fetch!(all, :broadcaster)
    Enum.map(list, fn top ->
      grab_depending(top, all, Map.new())
      |> Map.put(:broadcaster, {:broadcaster, :broadcaster, [top]})
      |> Map.values
    end)
  end

  defp grab_depending(name, all, acc) do
    if Map.has_key?(acc, name) do
      acc
    else
      case Map.get(all, name) do
        nil ->
          acc
        module ->
          acc = Map.put(acc, name, module)
          {_, _, list} = module
          Enum.reduce(list, acc, fn name, acc ->
            grab_depending(name, all, acc)
          end)
      end
    end
  end

  defp prepare_modules(input) do
    sources = Enum.flat_map(input, fn {_, name, destinations} ->
      Enum.map(destinations, &{&1, name})
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.new

    Enum.map(input, fn {type, name, destinations} ->
      case type do
        :broadcaster ->
          {name, {type, destinations, false}}
        :flipflop ->
          {name, {type, destinations, false}}
        :nand ->
          state = Map.fetch!(sources, name)
          |> Enum.map(&{&1, false})
          {name, {type, destinations, state}}
      end
    end)
    |> Map.new
  end

  defp solve_part2(input) do
    modules = prepare_modules(input)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(modules, fn steps, modules ->
      modules = Map.delete(modules, :rx)
      q = :queue.from_list([{:broadcaster, :broadcaster, false}])
      {_, modules} = pulse(q, modules)
      case Map.get(modules, :rx) do
        nil ->
          {:cont, modules}
        {:output, [], true} ->
          {:halt, steps}
      end
    end)
  end

  defp pulse(q, modules) do
    pulse(q, modules, 0, 0)
  end

  defp pulse(q, modules, low, high) do
    case :queue.out(q) do
      {:empty, _} ->
        {{low, high}, modules}
      {{:value,item}, q} ->
        {modules, items} = signal(modules, item)
        q = Enum.reduce(items, q, fn new_item, q ->
          :queue.in(new_item, q)
        end)
        case item do
          {_, _, false} ->
            pulse(q, modules, low + 1, high)
          {_, _, true} ->
            pulse(q, modules, low, high + 1)
        end
    end
  end

  defp signal(modules, {name, from, value}) do
    default = {:output, [], false}
    {type, destinations, state} = Map.get(modules, name, default)
    case type do
      :broadcaster ->
        {modules, Enum.map(destinations, &{&1, :broadcaster, false})}
      :flipflop ->
        case value do
          true ->
            {modules, []}
          false ->
            state = not state
            modules = Map.put(modules, name, {type, destinations, state})
            {modules, Enum.map(destinations, &{&1, name, state})}
        end
      :nand ->
        state = state
        |> Enum.map(fn {state_name, state_value} ->
           if state_name === from do
             {state_name, value}
           else
             {state_name, state_value}
           end
         end)
        output = not Enum.all?(state, &elem(&1, 1))
        modules = Map.put(modules, name, {type, destinations, state})
        {modules, Enum.map(destinations, &{&1, name, output})}
      :output ->
        if value === false do
          modules = Map.put(modules, name, {type, [], true})
          {modules, []}
        else
          {modules, []}
        end
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [id, signals] = String.split(line, " -> ")
      {type, name} = case id do
                       "%" <> name ->
                         {:flipflop, String.to_atom(name)}
                       "&" <> name ->
                         {:nand, String.to_atom(name)}
                       "broadcaster" ->
                         {:broadcaster, :broadcaster}
                     end
      signals = String.split(signals, ", ")
      |> Enum.map(&String.to_atom/1)
      {type, name, signals}
    end)
  end
end
