defmodule Day24 do
  def part1(input) do
    weights = parse(input)

    target = div(Enum.sum(weights), 3)

    q = init_queue(weights)
    all_solutions(q, target, :infinity, :infinity)
    |> Enum.sort
    |> hd
    |> elem(1)
    |> quantum_entanglement
  end

  def part2(input) do
    weights = parse(input)

    target = div(Enum.sum(weights), 4)

    q = init_queue(weights)
    all_solutions(q, target, :infinity, :infinity)
    |> Enum.sort
    |> hd
    |> elem(1)
    |> quantum_entanglement
  end

  defp all_solutions(q, target, num_weights, best_qe) do
    case solve(q, target, num_weights) do
      nil ->
        []
      {{included, _excluded}, q} ->
        case quantum_entanglement(included) do
          qe when qe < best_qe ->
            num_weights = min(num_weights, length(included))
            [{qe, included} | all_solutions(q, target, num_weights, qe)]
          _ ->
            all_solutions(q, target, num_weights, best_qe)
        end
    end
  end

  defp init_queue(weights) do
    weights = weights
    |> Enum.sort
    |> Enum.reverse

    Enum.map_reduce(weights, weights, fn weight, excluded ->
      excluded = excluded -- [weight]
      {{weight, [weight], excluded}, excluded}
    end)
    |> elem(0)
    |> :gb_sets.from_list
  end

  defp solve(q, target, num_weights) do
    case :gb_sets.is_empty(q) do
      true ->
        nil
      false ->
        {{largest, included, excluded}, q} = :gb_sets.take_largest(q)
        cond do
          largest == target ->
            {{included, excluded}, q}
          largest < target and length(included) < num_weights ->
            q = add_to_queue(q, largest, included, excluded, target)
            solve(q, target, num_weights)
          true ->
            solve(q, target, num_weights)
        end
    end
  end

  defp add_to_queue(q, current, included, excluded, target) do
    Enum.reduce(excluded, q, fn other, q ->
      current = current + other
      if (current <= target) do
        element = {current, [other | included], excluded -- [other]}
        :gb_sets.insert(element, q)
      else
        q
      end
    end)
  end

  defp quantum_entanglement(weights) do
    Enum.reduce(weights, 1, &(&1 * &2))
  end

  defp parse(input) do
    Enum.map(input, &String.to_integer/1)
  end
end
