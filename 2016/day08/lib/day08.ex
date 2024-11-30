defmodule Day08 do
  def part1(input, width \\ 50, height \\ 6) do
    Parser.parse(input)
    |> Enum.reduce(Screen.init(width, height), fn command, screen ->
      command(screen, command)
    end)
    |> Screen.print
    |> Screen.num_pixels_lit
  end

  defp command(screen, command) do
    case command do
      {:rect, cols, rows} ->
        Screen.rect(screen, rows, cols)
      {:rotate_column, col, n} ->
        Screen.rotate_column(screen, col, n)
      {:rotate_row, row, n} ->
        Screen.rotate_row(screen, row, n)
    end
  end
end

defmodule Screen do
  use Bitwise

  defstruct [:width, :height, :pixels]

  def init(width, height) do
    %Screen{width: width, height: height, pixels: List.duplicate(0, height)}
  end

  def rect(screen, rows, cols) do
    %Screen{pixels: pixels, width: width} = screen
    bits = ((1 <<< cols) - 1) <<< (width - cols)
    {first, rest} = Enum.split(pixels, rows)
    first = Enum.map(first, fn pixel_row ->
      pixel_row ||| bits
    end)
    pixels = first ++ rest
    %Screen{screen | pixels: pixels}
  end

  def rotate_column(screen, col, n) do
    %Screen{pixels: pixels, width: width, height: height} = screen

    col_pixels = pixels
    |> Stream.cycle
    |> Stream.drop(height - n)
    |> Enum.take(height)

    mask = 1 <<< (width - col - 1)

    pixels = pixels
    |> Enum.zip(col_pixels)
    |> Enum.map(fn {pixels, col_pixels} ->
      col_pixels = col_pixels &&& mask
      pixels = pixels &&& (bnot mask)
      pixels ||| col_pixels
    end)

    %Screen{screen | pixels: pixels}
  end

  def rotate_row(screen, row, n) do
    %Screen{pixels: pixels, width: width} = screen
    {first, [row_pixels | rest]} = Enum.split(pixels, row)
    mask = (1 <<< n) - 1
    fell_off = (row_pixels &&& mask)
    shift = width - n
    row_pixels = (row_pixels >>> n) ||| (fell_off <<< shift)
    pixels = first ++ [row_pixels] ++ rest
    %Screen{screen | pixels: pixels}
  end

  def num_pixels_lit(screen) do
    %Screen{pixels: pixels} = screen
    Enum.reduce(pixels, 0, fn row, count ->
      count + count_ones(row)
    end)
  end

  def print(screen) do
    %Screen{pixels: pixels, width: width} = screen
    Enum.map(pixels, fn row ->
      Enum.map(width - 1 .. 0, fn column ->
        case (row >>> column) &&& 1 do
          0 -> ?.
          1 -> ?\#
        end
      end)
      |> IO.puts
    end)
    IO.puts ""
    screen
  end

  def count_ones(n), do: count_ones(n, 0)

  def count_ones(0, count), do: count
  def count_ones(n, count), do: count_ones(n &&& (n - 1), count + 1)
end

defmodule Parser do
  import NimbleParsec

  defp pack([{tag, [a, b]}]) do
    {tag, a, b}
  end

  rect =
    ignore(string("rect "))
    |> integer(min: 1)
    |> ignore(string("x"))
    |> integer(min: 1)
    |> tag(:rect)

  rotate_row =
    ignore(string("rotate row y="))
    |> integer(min: 1)
    |> ignore(string(" by "))
    |> integer(min: 1)
    |> tag(:rotate_row)

  rotate_column =
    ignore(string("rotate column x="))
    |> integer(min: 1)
    |> ignore(string(" by "))
    |> integer(min: 1)
    |> tag(:rotate_column)

  defparsec :command,
    choice([rect, rotate_row, rotate_column])
    |> eos
    |> reduce({:pack, []})

  def parse(input) do
    Enum.map(input, fn line ->
      {:ok, [result], "", _, _, _} = command(line)
      result
    end)
  end
end
