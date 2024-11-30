defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part 1 with my input data" do
    assert Day22.part1(input()) == 987
  end

  test "part 2 with example" do
    assert Day22.part2(example()) == 7
  end

  test "part 2 with my input data" do
    assert Day22.part2(input()) == 220
  end

  defp example() do
    """
    root@ebhq-gridcenter# df -h
    Filesystem            Size  Used  Avail  Use%
    /dev/grid/node-x0-y0   10T    8T     2T   80%
    /dev/grid/node-x0-y1   11T    6T     5T   54%
    /dev/grid/node-x0-y2   32T   28T     4T   87%
    /dev/grid/node-x1-y0    9T    7T     2T   77%
    /dev/grid/node-x1-y1    8T    0T     8T    0%
    /dev/grid/node-x1-y2   11T    7T     4T   63%
    /dev/grid/node-x2-y0   10T    6T     4T   60%
    /dev/grid/node-x2-y1    9T    8T     1T   88%
    /dev/grid/node-x2-y2    9T    6T     3T   66%
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
