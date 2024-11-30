defmodule Day15 do
  def part1(input) do
    parse(input)
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&hash/1)
    |> Enum.sum
  end

  def part2(input) do
    boxes = 0..255
    |> Enum.map(&{&1, []})
    |> Map.new

    parse(input)
    |> Enum.reduce(boxes, fn command, boxes ->
      [label, focal] = String.split(command, ["=", "-"])
      box = hash(String.to_charlist(label))
      contents = Map.fetch!(boxes, box)
      contents = if focal === "" do
        List.keydelete(contents, label, 0)
      else
        focal = String.to_integer(focal)
        case List.keymember?(contents, label, 0) do
          true ->
            List.keyreplace(contents, label, 0, {label, focal})
          false ->
            [{label, focal} | contents]
        end
      end
      Map.put(boxes, box, contents)
    end)
    |> Enum.reject(fn {_, contents} -> contents === [] end)
    |> Enum.map(fn {box, contents} ->
      Enum.reverse(contents)
      |> Enum.with_index(1)
      |> Enum.reduce(0, fn {{_label, focal}, slot}, acc ->
        acc + (1 + box) * slot * focal
      end)
    end)
    |> Enum.sum
  end

  defp hash(string) do
    Enum.reduce(string, 0, fn ascii, acc ->
      rem((acc + ascii) * 17, 256)
    end)
  end

  defp parse(input) do
    input
    |> Enum.flat_map(fn line ->
      String.split(line, ",")
    end)
  end
end
