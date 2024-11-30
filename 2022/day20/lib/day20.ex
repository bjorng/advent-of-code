defmodule Day20 do
  def part1(input) do
    solve(input, 1, &(&1))
  end

  def part2(input) do
    decryption_key = 811589153
    solve(input, 10, fn list ->
      Enum.map(list, fn n -> n * decryption_key end)
    end)
  end

  defp solve(input, times, pre_process) do
    parse(input)
    |> mix(times, pre_process)
    |> Stream.cycle
    |> Stream.drop_while(&(&1 !== 0))
    |> Stream.with_index
    |> Stream.flat_map(fn {value, index} ->
      case rem(index, 1000) do
        0 -> [value]
        _ -> []
      end
    end)
    |> Enum.take(4)
    |> Enum.sum
  end

  defp mix(list, times, pre_process) do
    n = length(list) - 1
    list = pre_process.(list)
    list = Enum.with_index(list)
    Enum.reduce(1..times, list, fn _, list ->
      Enum.reduce(0..n, list, fn index, list ->
        do_mix(list, index, [])
      end)
    end)
    |> Enum.map(&elem(&1, 0))
  end

  defp do_mix([{n, index} | tail], index, acc) do
    if n >= 0 do
      move_forward(n, {n, index}, tail, acc)
    else
      move_backward(-n, {n, index}, acc, tail)
    end
  end
  defp do_mix([head | rest], index, acc) do
    do_mix(rest, index, [head | acc])
  end

  defp move_forward(0, n, tail, acc) do
    Enum.reverse(acc, [n | tail])
  end
  defp move_forward(left, n, [head | tail], acc) do
    move_forward(left - 1, n, tail, [head | acc])
  end
  defp move_forward(left, n, [], acc) do
    left = rem(left, length(acc))
    list = Enum.reverse(acc)
    move_forward(left, n, list, [])
  end

  defp move_backward(0, n, tail, acc) do
    Enum.reverse(tail, [n | acc])
  end
  defp move_backward(left, n, [head | tail], acc) do
    move_backward(left - 1, n, tail, [head | acc])
  end
  defp move_backward(left, n, [], acc) do
    left = rem(left, length(acc))
    move_backward(left, n, Enum.reverse(acc), [])
  end

  defp parse(input) do
    input
    |> Enum.map(&String.to_integer/1)
  end
end
