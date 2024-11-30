defmodule Day13 do
  def part1(input) do
    parse(input)
    |> Enum.chunk_every(2)
    |> Enum.with_index(1)
    |> Enum.filter(fn {[a, b], _index} ->
      cmp(a, b) === -1
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum
  end

  def part2(input) do
    [[[2]], [[6]] | parse(input)]
    |> Enum.sort(fn a, b -> cmp(a, b) <= 0 end)
    |> Enum.with_index(1)
    |> Enum.filter(fn {package, _index} ->
      case package do
        [[2]] -> true
        [[6]] -> true
        _ -> false
      end
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.product
  end

  defp cmp([h1 | t1], [h2 | t2]) do
    case cmp(h1, h2) do
      0 -> cmp(t1, t2)
      other -> other
    end
  end
  defp cmp([], [_ | _]) do
    -1
  end
  defp cmp([_ | _], []) do
    1
  end
  defp cmp([], []) do
    0
  end
  defp cmp(a, b) when is_integer(a) and is_integer(b) do
    cond do
      a < b -> -1
      a == b -> 0
      a > b -> 1
    end
  end
  defp cmp(a, b) when is_integer(a) and is_list(b) do
    cmp([a], b)
  end
  defp cmp(a, b) when is_list(a) and is_integer(b) do
    cmp(a, [b])
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      Code.eval_string(line)
      |> elem(0)
    end)
  end
end
