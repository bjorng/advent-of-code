#
# Part 2 is a bit slow, but finishes in about 4 minutes on my computer.
#

defmodule Day11 do
  def part1(serial) do
    {{x, y}, _} = largest_total_power(serial)
    "#{x},#{y}"
  end

  def part2(serial) do
    {{x, y, size}, _} = largest_total_square(serial)
    "#{x},#{y},#{size}"
  end

  def largest_total_square serial do
    grid = build_grid serial
    acc = {{0, 0, 0}, 0}
    Enum.reduce(1..299, acc, fn x, acc ->
      Enum.reduce(1..299, acc, fn y, acc ->
	find_largest(x, y, grid, acc)
      end)
    end)
  end

  def find_largest x, y, grid, acc do
    max_square_size = min(301 - x, 301 - y)
    level = grid[{x, y}]
    {best, _} =
      Enum.reduce(2..max_square_size, {acc, level},
	fn square_size, {{_coord, prev_level} = prev, level} ->
	  level = sum_square(x, y, square_size, grid, level)
	  if level > prev_level do
	    {{{x, y, square_size}, level}, level}
	  else
	    {prev, level}
	  end
	end)
    best
  end

  def sum_square(x0, y0, square_size, grid, acc) do
    y = y0 + square_size - 1;
    acc = Enum.reduce(x0..x0 + square_size-2, acc,
      fn x, acc ->
	acc + grid[{x, y}]
      end)
    x = x0 + square_size - 1;
    acc = Enum.reduce(y0..y0 + square_size-1, acc,
      fn y, acc ->
	acc + grid[{x, y}]
      end)
    acc
  end

  @doc """
  Calculate 3 x 3 square with largest total power.

  ## Examples

      iex> Day11.largest_total_power(18)
      {{33, 45}, 29}
      iex> Day11.largest_total_power(42)
      {{21, 61}, 30}

  """
  def largest_total_power serial do
    grid = build_grid serial

    for x <- 1..298,
      y <- 1..298 do
      {{x, y}, sum_three_by_three(x, y, grid)}
    end
    |> Enum.max_by(&elem(&1, 1))
  end

  def build_grid serial do
    for x <- 1..300,
      y <- 1..300,
      into: %{} do
      {{x, y}, cell_power_level(x, y, serial)}
    end
  end

  @doc """
  Sum of 3 x 3 square total cell power.

  ## Examples

      iex> Day11.sum_three_by_three(21, 61, Day11.build_grid(42))
      30

  """
  def sum_three_by_three x0, y0, grid do
    Enum.reduce(x0..x0+2, 0, fn x, acc ->
      Enum.reduce(y0..y0+2, acc, fn y, acc ->
	  acc + grid[{x, y}]
      end)
    end)
  end

  @doc """
  Calculate cell power level.

  ## Examples

      iex> Day11.cell_power_level(3, 5, 8)
      4
      iex> Day11.cell_power_level(122, 79, 57)
      -5
      iex> Day11.cell_power_level(217, 196, 39)
      0
      iex> Day11.cell_power_level(101, 153, 71)
      4
      iex> Day11.cell_power_level(21, 61, 42)
      4
      iex> Day11.cell_power_level(21, 62, 42)
      3
      iex> Day11.cell_power_level(21, 63, 42)
      3
      iex> Day11.cell_power_level(22, 61, 42)
      3
      iex> Day11.cell_power_level(22, 62, 42)
      3
      iex> Day11.cell_power_level(22, 63, 42)
      3
      iex> Day11.cell_power_level(23, 61, 42)
      3
      iex> Day11.cell_power_level(23, 62, 42)
      4
      iex> Day11.cell_power_level(23, 63, 42)
      4

  """
  def cell_power_level x, y, serial do
    rack_id = x + 10
    power = rack_id * (rack_id * y + serial)
    rem(div(power, 100), 10) - 5
  end
end
