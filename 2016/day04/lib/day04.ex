defmodule Day04 do
  def part1(input) do
    parse(input)
    |> Enum.filter(&is_real_room/1)
    |> Enum.map(&elem(&1, 2))
    |> Enum.sum
  end

  def part2(input) do
    parse(input)
    |> Enum.filter(&is_real_room/1)
    |> Enum.find_value(fn {_, _, id} = room ->
      shift_cipher(room) === "northpole object storage" && id
    end)
  end

  def test_shift_cipher(room) do
    [room] = parse([room])
    shift_cipher(room)
  end

  defp shift_cipher({name, _checksum, id}) do
    translation = ?a..?z
    |> Stream.cycle
    |> Stream.drop(rem(id, 26))
    |> Enum.take(26)
    |> Enum.with_index(?a)
    |> Enum.map(fn {a, b} -> {b, a} end)
    |> Map.new
    |> Map.put(?-, ?\s)

    String.to_charlist(name)
    |> Enum.map(fn char -> Map.fetch!(translation, char) end)
    |> List.to_string
  end

  defp is_real_room({name, checksum, _id}) do
    String.to_charlist(name)
    |> Enum.frequencies
    |> Map.delete(?-)
    |> Map.to_list
    |> Enum.sort(fn {letter1, freq1}, {letter2, freq2} ->
      freq1 > freq2 || (freq1 === freq2 && letter1 <= letter2)
    end)
    |> Enum.take(5)
    |> Enum.map(&elem(&1, 0))
    |> List.to_string
    |> Kernel.===(checksum)
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      parts = String.split(line, "-")
      {checksum, parts} = List.pop_at(parts, -1)
      {id, checksum} = Integer.parse(checksum)
      name = Enum.join(parts, "-")
      checksum = String.slice(checksum, 1..5)
      {name, checksum, id}
    end)
  end
end
