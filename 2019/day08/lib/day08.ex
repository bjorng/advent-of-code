defmodule Day08 do
  def part1(input, width, height) do
    layer_size = width * height
    layers = split_layers(input, layer_size)
    layers
    |> Stream.map(fn layer ->
      {layer, num_chars(layer, ?0)}
    end)
    |> Enum.min_by(&(elem(&1, 1)))
    |> result()
  end

  def part2(input, width, height) do
    layer_size = width * height
    layers = split_layers(input, layer_size)
    compose(layers)
    |> Enum.chunk_every(width)
    |> print_image
    nil
  end

  defp result({layer, _}) do
    num_chars(layer, ?1) * num_chars(layer, ?2)
  end

  defp compose([bottom]) do
    String.to_charlist(bottom)
  end
  defp compose([layer|layers]) do
    below = compose(layers)
    compose(to_charlist(layer), below)
  end

  defp compose([?2 | pixels1], [pixel | pixels2]) do
    [pixel | compose(pixels1, pixels2)]
  end
  defp compose([pixel | pixels1], [_ | pixels2]) do
    [pixel | compose(pixels1, pixels2)]
  end
  defp compose([], []), do: []

  defp print_image([line | t]) do
    IO.write('\n')
    print_line(line)
    print_image(t)
  end
  defp print_image([]), do: IO.write('\n')

  defp print_line([char | chars]) do
    case char do
      ?0 -> IO.write(' ')
      ?1 -> IO.write('*')
    end
    print_line(chars)
  end
  defp print_line([]), do: nil

  defp num_chars(string, char) do
    String.to_charlist(string)
    |> Stream.filter(&(&1 === char))
    |> Enum.count
  end

  defp split_layers(string, layer_size) do
    case String.split_at(string, layer_size) do
      {layer, ""} ->
	[layer]
      {layer, rest} ->
	[layer | split_layers(rest, layer_size)]
    end
  end
end
