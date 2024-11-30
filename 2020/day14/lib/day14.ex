defmodule Day14 do
  import Bitwise

  def part1(input) do
    BitmaskParser.parse(input)
    |> Enum.reduce(%{mask: {-1, 0}}, &execute_part1/2)
    |> Enum.map(fn {addr, value} ->
      case addr do
        :mask -> 0
        _ -> value
      end
    end)
    |> Enum.sum
  end

  def part2(input) do
    BitmaskParser.parse(input)
    |> Enum.reduce(%{mask: {-1, 0}}, &execute_part2/2)
    |> Enum.map(fn {addr, value} ->
      case addr do
        :mask -> 0
        _ -> value
      end
    end)
    |> Enum.sum
  end

  defp execute_part1({:mask, mask}, mem) do
    mask = prepare_mask(mask, 0, 0)
    %{mem | mask: mask}
  end
  defp execute_part1({:memory, address, value}, mem) do
    %{mask: {and_mask, or_mask}} = mem
    value = (value &&& and_mask) ||| or_mask
    Map.put(mem, address, value)
  end

  defp execute_part2({:mask, mask}, mem) do
    mask = prepare_mask(mask, 0, 0)
    %{mem | mask: mask}
  end
  defp execute_part2({:memory, address, value}, mem) do
    %{mask: {and_mask, or_mask}} = mem
    and_mask = bnot(and_mask)
    address = (address &&& and_mask) ||| or_mask
    mem = Map.put(mem, address, value)
    write_all(1, and_mask, mem, address, value)
  end

  defp write_all(bit, _, mem, _, _) when bit >= 1 <<< 36, do: mem
  defp write_all(bit, and_mask, mem, address, value) do
    if (bit &&& and_mask) === 0 do
      mem = Map.put(mem, address, value)
      mem = Map.put(mem, address ||| bit, value)
      mem = write_all(bit <<< 1, and_mask, mem, address, value)
      write_all(bit <<< 1, and_mask, mem, address ||| bit, value)
    else
      write_all(bit <<< 1, and_mask, mem, address, value)
    end
  end

  def prepare_mask(<<bit::size(8), next::binary>>, and_mask, or_mask) do
    and_mask = and_mask <<< 1
    or_mask = or_mask <<< 1
    case bit do
      ?X ->
        prepare_mask(next, and_mask ||| 1, or_mask)
      _ ->
        prepare_mask(next, and_mask, or_mask ||| (bit - ?0))
    end
  end
  def prepare_mask(<<>>, and_mask, or_mask), do: {and_mask, or_mask}
end

defmodule BitmaskParser do
  import NimbleParsec

  defp memory([address, value]) do
    {:memory, address, value}
  end

  set_mask = ignore(string("mask = "))
  |> ascii_string([?0,?1,?X], min: 36)
  |> unwrap_and_tag(:mask)
  |> eos()

  set_memory = ignore(string("mem["))
  |> integer(min: 1)
  |> ignore(string("] = "))
  |> integer(min: 1)
  |> eos()
  |> reduce({:memory, []})

  defparsecp :assignment,
    choice([set_mask, set_memory])

  def parse(input) do
    Enum.map(input, fn(line) ->
      {:ok, [res], _, _, _, _} = assignment(line)
      res
    end)
  end
end
