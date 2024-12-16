defmodule Day21 do
  defmodule Keypad do
    defstruct position: {0, 0}, grid: %{}, parse: nil

    def init(grid, parse_char) do
      grid = grid
      |> String.split("\n", trim: true)
      |> parse_grid(parse_char)
      {position, _} = Enum.find(grid, fn {_, button} ->
        button === :activate
      end)
      %Keypad{position: position, grid: grid, parse: parse_char}
    end

    def press(pad, button) do
      button = pad.parse.(button)
      {to, _} = Enum.find(pad.grid, fn {_, b} -> b === button end)
      diff = sub(pad.position, to)
      moves = do_press(diff, to, pad.grid)
      Enum.each(moves, fn move ->
        ^to = Enum.reduce(move, pad.position, &add/2)
      end)
      moves = Enum.map(moves, fn move ->
        Enum.map(move, &symbolic_dir/1) ++ [?A]
      end)
      moves = case moves do
                [move] -> move
                _ -> [{:alt, moves}]
              end
      pad = %{pad | position: to}

      {moves, pad}
    end

    defp do_press({0, 0}, _to, _grid), do: [[]]
    defp do_press(diff, to, grid) do
      [{-1, 0}, {0, -1}, {0, 1}, {1, 0}]
      |> Enum.filter(fn dir ->
        new_diff = add(diff, dir)
        new_pos = add(to, new_diff)
        Map.has_key?(grid, new_pos) and
        distance(new_diff) < distance(diff) and
        Map.fetch!(grid, add(to, new_diff)) !== :panic
      end)
      |> Enum.flat_map(fn dir ->
        new_diff = add(diff, dir)
        do_press(new_diff, to, grid)
        |> Enum.map(fn path ->
          [dir | path]
        end)
      end)
    end

    defp distance({a, b}), do: abs(a) + abs(b)

    defp symbolic_dir(dir) do
      case dir do
        {-1, 0} -> ?^
        {1, 0} -> ?v
        {0, -1} -> ?<
        {0, 1} -> ?>
      end
    end

    defp add({a, b}, {c, d}), do: {a + c, b + d}

    defp sub({a, b}, {c, d}), do: {a - c, b - d}

    defp parse_grid(grid, parse_char) do
      grid
      |> Enum.with_index
      |> Enum.flat_map(fn {line, row} ->
        String.to_charlist(line)
        |> Enum.with_index
        |> Enum.map(fn {char, col} ->
          position = {row, col}
          {position, parse_char.(char)}
        end)
      end)
      |> Map.new
    end
  end

  def part1(input) do
    solve(input, 3)
  end

  def part2(input) do
    solve(input, 26)
  end

  defp solve(input, num_robots) do
    dir_pad = make_directional_keypad()
    pads = [make_numeric_keypad() | List.duplicate(dir_pad, num_robots - 1)]

    parse(input)
    |> Enum.map(fn {num, code} ->
      String.to_charlist(code)
      |> press(pads)
      |> then(&num * &1)
    end)
    |> Enum.sum
  end

  defp count(s), do: count(s, 0)

  # Characters counts are enclosed in a tuple to distinguish
  # them from characters (that also are integers).
  # This is necessary as the count/1 function will be called
  # multiple times.
  defp count(char, n) when is_integer(char), do: {n + 1}
  defp count({n1}, n), do: {n + n1}
  defp count({:alt,alts}, n) do
    Enum.map(alts, fn alt ->
      count(alt, 0)
    end)
    |> Enum.min
    |> then(fn {n1} -> {n + n1} end)
  end
  defp count([h|t], n) do
    {n1} = count(h)
    count(t, n + n1)
  end
  defp count([], n), do: {n}

  defp press(buttons, pads) do
    {result, _} = do_press(buttons, pads)
    {n} = count(result)
    n
  end

  #
  # This is surprisingly fast. Here is why:
  #
  # * It is only necessary to keep the fully expanded button sequences
  #   for one numeric button at a time.
  #
  # * When we have that sequence, we can immediately count the number
  #   of characters and only keep that count.
  #
  # * Memoization using the process dictionary saves **many**
  #   calculations.
  #

  defp do_press(buttons, pads) do
    Enum.map_reduce(buttons, pads, fn button, pads ->
      case pads do
        [] ->
          {count([button]), []}
        [pad|pads] ->
          cache_key = {button, pad.position, length(pads)}
          case Process.get(cache_key) do
            nil ->
              case button do
                {:alt, [alt|alts]} ->
                  {first, [pad|pads]} = do_press(alt, [pad|pads])
                  rest = Enum.map(alts, fn alt ->
                    {buttons, _} = do_press(alt, [pad|pads])
                    buttons
                  end)
                  {count({:alt, [first|rest]}), [pad|pads]}
                _ when is_integer(button) ->
                  {buttons, pad} = Keypad.press(pad, button)
                  {buttons, pads} = do_press(buttons, pads)
                  {count(buttons), [pad|pads]}
              end
              |> then(fn {value, [pad|_]=pads} ->
                Process.put(cache_key, {value, pad})
                {value, pads}
              end)
            {value, pad} ->
              {value, [pad|pads]}
          end
      end
    end)
  end

  defp make_numeric_keypad() do
    parse = fn char ->
      case char do
        _ when char in ?0..?9 -> char - ?0
        ?A -> :activate
        ?. -> :panic
      end
    end
    """
    789
    456
    123
    .0A
    """
    |> Keypad.init(parse)
  end

  defp make_directional_keypad() do
    parse = &vector_dir/1
    """
    .^A
    <v>
    """
    |> Keypad.init(parse)
  end

  defp vector_dir(char) do
    case char do
        ?^ -> {-1, 0}
        ?< -> {0, -1}
        ?> -> {0, 1}
        ?v -> {1, 0}
        ?. -> :panic
        ?A -> :activate
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      {Integer.parse(line) |> elem(0), line}
    end)
  end
end
