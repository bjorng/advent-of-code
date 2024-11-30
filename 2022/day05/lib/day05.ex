defmodule Day05 do
  def part1(input) do
    solve(input, &move_stack_part1/3)
  end

  defp move_stack_part1(n, from, to) do
    {moved, from} = Enum.split(from, n)
    to = Enum.reverse(moved, to)
    {from, to}
  end

  def part2(input) do
    solve(input, &move_stack_part2/3)
  end

  defp move_stack_part2(n, from, to) do
    {moved, from} = Enum.split(from, n)
    to = moved ++ to
    {from, to}
  end

  defp solve(input, move_stack) do
    {stacks, moves} = parse(input)

    stacks = stacks
    |> Enum.with_index(fn element, index -> {index + 1, element} end)
    |> Map.new

    Enum.reduce(moves, stacks, fn {n, from, to}, stacks ->
      %{^from => from_stack, ^to => to_stack} = stacks
      {from_stack, to_stack} = move_stack.(n, from_stack, to_stack)
      %{stacks | from => from_stack, to => to_stack}
    end)
    |> Map.to_list
    |> Enum.sort
    |> Enum.map(fn {_, [crate | _]} -> crate end)
    |> List.to_string
  end

  defp parse(input) do
    {stacks, rest} = parse_stacks(input)
    {stacks, rest}
  end

  defp parse_stacks([line | _] = lines) do
    num_stacks = div(String.length(line) + 1, 4)
    {stacks, lines} = parse_stacks(lines, List.duplicate([], num_stacks))
    moves = Enum.map(lines, &parse_move/1)
    {stacks, moves}
  end

  defp parse_stacks([line | lines], stacks) do
    case parse_stack_row(line <> " ", stacks) do
      :done ->
        stacks = Enum.map(stacks, &Enum.reverse/1)
        {stacks, lines}
      stacks ->
        parse_stacks(lines, stacks)
    end
  end

  defp parse_stack_row(<<"[", crate, "] ", row::binary>>, [stack | stacks]) do
    [[crate | stack] | parse_stack_row(row, stacks)]
  end
  defp parse_stack_row("    " <> row, [stack | stacks]) do
    [stack | parse_stack_row(row, stacks)]
  end
  defp parse_stack_row("", stacks) do
    stacks
  end
  defp parse_stack_row(" 1" <> _, _stacks) do
    :done
  end

  defp parse_move("move " <> rest) do
    {amount, " from " <> rest} = Integer.parse(rest)
    {from, " to " <> rest} = Integer.parse(rest)
    {to, ""} = Integer.parse(rest)
    {amount, from, to}
  end
end
