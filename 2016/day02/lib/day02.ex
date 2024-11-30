defmodule Keypad do
  defmacro defkeypad(name, keypad) do
    button_var = quote do var!(button) end
    default = [{button_var, quote do var!(_) end, button_var}]
    fsm = build_fsm(keypad) ++ default
    for {button, action, next_button} <- fsm do
      quote do
        defp unquote(name)(unquote(button), unquote(action)), do: unquote(next_button)
      end
    end
  end

  defp build_fsm(keypad) do
    list = keypad
    |> String.split("\n", trim: true)
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.split(line, "", trim: true)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        case char do
          "." ->
            []
          _ ->
            [{{row, col}, String.to_integer(char, 16)}]
        end
      end)
    end)
    map = Map.new(list)
    directions = [{:up, {-1, 0}}, {:down, {1, 0}},
                  {:left, {0, -1}}, {:right, {0, 1}}]
    Enum.flat_map(list, fn {location, button} ->
      Enum.flat_map(directions, fn {dir, vec} ->
        key = vec_add(location, vec)
        case map do
          %{^key => next_button} ->
            [{button, dir, next_button}]
          %{} ->
            []
        end
      end)
    end)
    |> Enum.sort
  end

  defp vec_add({row, col}, {dr, dc}), do: {row + dr, col + dc}
end

defmodule Day02 do
  import Keypad

  def part1(input) do
    solve(input, &move_part1/2)
    |> Enum.reduce(0, fn digit, acc ->
      acc * 10 + digit
    end)
  end

  def part2(input) do
    solve(input, &move_part2/2)
    |> Enum.reduce(0, fn digit, acc ->
      acc * 16 + digit
    end)
    |> Integer.to_string(16)
  end

  defp solve(input, move) do
    parse(input)
    |> Enum.map_reduce(5, fn line, button ->
      button =
        Enum.reduce(line, button, fn command, button ->
          move.(button, command)
        end)
      {button, button}
    end)
    |> elem(0)
  end

  defkeypad(:move_part1,
  """
  123
  456
  789
  """)

  defkeypad(:move_part2,
  """
  ..1..
  .234.
  56789
  .ABC.
  ..D..
  """)

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.to_charlist(line)
      |> Enum.map(fn char ->
        case char do
          ?U -> :up
          ?D -> :down
          ?L -> :left
          ?R -> :right
        end
      end)
    end)
  end
end
