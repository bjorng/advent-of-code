defmodule Day03 do
  def part1(input) do
    count_trees(input, [{3,1}])
  end

  def part2(input) do
    slopes = [{1,1}, {3,1}, {5,1}, {7,1}, {1,2}]
    count_trees(input, slopes)
  end

  defp count_trees(input, slopes) do
    grid = make_grid(input)
    Enum.reduce(slopes, 1, fn slope, acc ->
      trees = Stream.iterate({0, 0}, &(move(&1, slope)))
      |> Enum.reduce_while(0, fn pos, trees ->
        case at(grid, pos) do
          nil ->
            {:halt, trees}
          ?\# ->
            {:cont, trees + 1}
          ?. ->
            {:cont, trees}
        end
      end)
      acc * trees
    end)
  end

  defp move({x, y}, {dx, dy}) do
    {x+dx, y+dy}
  end

  defp make_grid(lines) do
    width = byte_size(hd(lines))
    height = length(lines)
    {width, height, :erlang.iolist_to_binary(lines)}
  end

  defp at({width, height, grid}, {x, y}) when y < height do
    :binary.at(grid, y * width + rem(x, width))
  end
  defp at(_, _), do: nil
end
