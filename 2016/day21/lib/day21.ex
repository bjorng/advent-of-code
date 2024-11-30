defmodule Day21 do
  def part1(rules, string) do
    Parser.parse(rules)
    |> Enum.reduce(string, &execute/2)
  end

  def part2(rules, string) do
    Parser.parse(rules)
    |> Enum.reverse
    |> Enum.map(&reverse_command/1)
    |> Enum.reduce(string, &execute/2)
  end

  defp execute(command, string) do
    case command do
      {:move, pos1, pos2} ->
        {prefix, rest} = String.split_at(string, pos1)
        {char, suffix} = String.split_at(rest, 1)
        string = prefix <> suffix
        {prefix, suffix} = String.split_at(string, pos2)
        prefix <> char <> suffix
      {:reverse, pos1, pos2} ->
        {prefix, rest} = String.split_at(string, pos1)
        {subject, suffix} = String.split_at(rest, pos2 - pos1 + 1)
        prefix <> String.reverse(subject) <> suffix
      {:rotate, :left, amount} ->
        rotate_left(string, amount)
      {:rotate, :right, amount} ->
        rotate_right(string, amount)
      {:rotate_based, letter} ->
        rotate_based(string, letter)
      {:rotate_based_reversed, letter} ->
        rotate_based_reversed(string, letter, string)
      {:swap_position, pos1, pos2} ->
        char1 = String.at(string, pos1)
        char2 = String.at(string, pos2)
        string
        |> string_put(pos1, char2)
        |> string_put(pos2, char1)
      {:swap_letter, letter1, letter2} ->
        string
        |> String.replace(letter1, "\0")
        |> String.replace(letter2, letter1)
        |> String.replace("\0", letter2)
    end
  end

  defp rotate_based_reversed(string, letter, goal) do
    case rotate_based(string, letter) do
      ^goal -> string
      _ -> rotate_based_reversed(rotate_left(string, 1), letter, goal)
    end
  end

  defp rotate_based(string, letter) do
    [prefix, _] = String.split(string, letter)
    index = byte_size(prefix)
    amount = if index >= 4, do: index + 2, else: index + 1
    rotate_right(string, amount)
  end

  defp rotate_left(string, amount) do
    amount = rem(amount, byte_size(string))
    {prefix, suffix} = String.split_at(string, amount)
    suffix <> prefix
  end

  defp rotate_right(string, amount) do
    amount = rem(amount, byte_size(string))
    {prefix, suffix} = String.split_at(string, -amount)
    suffix <> prefix
  end

  defp string_put(string, position, char) do
    <<prefix::binary-size(position), _::size(8), suffix::binary>> = string
    prefix <> char <> suffix
  end

  defp reverse_command(command) do
    case command do
      {:move, pos1, pos2} ->
        {:move, pos2, pos1}
      {:rotate, dir, amount} ->
        dir = case dir do
                :left -> :right
                :right -> :left
              end
        {:rotate, dir, amount}
      {:rotate_based, letter} ->
        {:rotate_based_reversed, letter}
      _ ->
        command
    end
  end
end

defmodule Parser do
  import NimbleParsec

  defp pack(list, tag) do
    List.to_tuple([tag | list])
  end

  defp to_atom([word]), do: String.to_atom(word)

  blank = ignore(optional(ascii_char([?\s])))

  letter = ascii_string([?a..?z], min: 1)

  swap_position = ignore(string("swap position "))
  |> integer(min: 1)
  |> ignore(string(" with position "))
  |> integer(min: 1)
  |> reduce({:pack, [:swap_position]})

  swap_letter = ignore(string("swap letter "))
  |> concat(letter)
  |> ignore(string(" with letter "))
  |> concat(letter)
  |> reduce({:pack, [:swap_letter]})

  reverse = ignore(string("reverse positions "))
  |> integer(min: 1)
  |> ignore(string(" through "))
  |> integer(min: 1)
  |> reduce({:pack, [:reverse]})

  side = choice([string("left"), string("right")])
  |> reduce({:to_atom, []})

  rotate_side = ignore(string("rotate "))
  |> concat(side)
  |> concat(blank)
  |> integer(min: 1)
  |> ignore(string(" step") |> optional(string("s")))
  |> reduce({:pack, [:rotate]})

  rotate_based = ignore(string("rotate based on position of letter "))
  |> concat(letter)
  |> unwrap_and_tag(:rotate_based)

  move = ignore(string("move position "))
  |> integer(min: 1)
  |> ignore(string(" to position "))
  |> integer(min: 1)
  |> reduce({:pack, [:move]})

  defparsec :command, choice([swap_letter, swap_position, reverse,
                              rotate_side, rotate_based, move])

  def parse(input) do
    Enum.map(input, fn line ->
      {:ok, [result], "", _, _, _} = command(line)
      result
    end)
  end
end
