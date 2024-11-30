defmodule Day07 do
  def part1(input) do
    parse(input)
    |> Enum.count(&supports_tls?/1)
  end

  def part2(input) do
    parse(input)
    |> Enum.count(&supports_ssl?/1)
  end

  defp supports_tls?({plain_parts, hyper_parts}) do
    Enum.any?(plain_parts, &has_abba?/1) and
    Enum.all?(hyper_parts, fn part -> not has_abba?(part) end)
  end

  defp has_abba?([first, second, second, first | _]) when first !== second, do: true
  defp has_abba?([_ | tail]), do: has_abba?(tail)
  defp has_abba?([]), do: false

  defp supports_ssl?({plain_parts, hyper_parts}) do
    case Enum.flat_map(plain_parts, &find_abas/1) do
      [] ->
        false
      babs ->
        babs = :binary.compile_pattern(babs)
        Enum.any?(hyper_parts, fn part ->
          String.contains?(List.to_string(part), babs)
        end)
    end
  end

  defp find_abas(part), do: find_abas(part, [])

  defp find_abas([], acc), do: acc
  defp find_abas([a, b, a | tail], acc) when a !== b do
    bab = List.to_string([b, a, b])
    find_abas([b, a | tail], [bab | acc])
  end
  defp find_abas([_ | tail], acc) do
    find_abas(tail, acc)
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      line
      |> String.to_charlist
      |> Enum.chunk_by(&(&1 in ?a..?z))
      |> parse_parts([], [])
    end)
  end

  defp parse_parts([], plain, hyper), do: {plain, hyper}
  defp parse_parts(['[', part, ']' | parts], plain, hyper) do
    parse_parts(parts, plain, [part | hyper])
  end
  defp parse_parts([part | parts], plain, hyper) do
    parse_parts(parts, [part | plain], hyper)
  end
end
