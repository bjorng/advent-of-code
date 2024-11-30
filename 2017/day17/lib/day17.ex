defmodule Day17 do
  def part1(steps) do
    [{buf, pos, _}] = spinlock_stream(steps)
    |> Stream.drop(2017)
    |> Enum.take(1)
    Enum.at(buf, rem(pos + 1, 2017 + 1))
  end

  def part2(steps) do
    lazy_solve(steps, 50_000_000)
  end

  def solve(steps, iters) do
    value = brute_solve(steps, iters)
    ^value = lazy_solve(steps, iters)
  end

  defp brute_solve(steps, iters) do
    [{buf, _, _}] = spinlock_stream(steps)
    |> Stream.drop(iters)
    |> Enum.take(1)
    index = Enum.find_index(buf, & &1 === 0)
    if index > iters do
      hd(buf)
    else
      Enum.at(buf, index + 1)
    end
  end

  def lazy_solve(steps, iters) do
    [{after_zero, _, _}] = lazy_spinlock_stream(steps)
    |> Stream.drop(iters)
    |> Enum.take(1)
    after_zero
  end

  defp spinlock_stream(steps) do
    Stream.iterate({[0], 0, 1}, & next_step(&1, steps))
  end

  defp next_step({buf, pos, n}, steps) do
    pos = rem(pos + steps, n) + 1
    {List.insert_at(buf, pos, n), pos, n + 1}
  end

  defp lazy_spinlock_stream(steps) do
    Stream.iterate({nil, 0, 1}, & next_lazy_step(&1, steps))
  end

  defp next_lazy_step({after_zero, pos, n}, steps) do
    pos = rem(pos + steps, n) + 1
    {case pos do
       1 -> n
       _ -> after_zero
     end, pos, n + 1}
  end
end
