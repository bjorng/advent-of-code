defmodule Day18 do
  def part1(input) do
    solve(input, false)
  end

  def part2(input) do
    solve(input, true)
  end

  def solve(input, precedence) do
    Enum.map(input, &scan_expr/1)
    |> Enum.map(fn line -> parse_expr(line, precedence) end)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.map(&eval_expr/1)
    |> Enum.sum
  end

  defp eval_expr(expr) do
    case expr do
      {op, args} ->
        args = Enum.map(args, &eval_expr/1)
        apply(:erlang, op, args)
      number when is_integer(number) ->
        number
    end
  end

  defp parse_expr(tokens, precedence) do
    {lhs, tokens} = parse_term(tokens, precedence)
    parse_op_expr(lhs, tokens, precedence)
  end

  defp parse_op_expr(lhs, tokens, precedence) do
    case tokens do
      [] ->
        {lhs, []}
      [:rparen | _] ->
        {lhs, tokens}
      [{:operator, op} | tokens] when op == :+ or precedence == false ->
        # Handle + and * for part 1 and + for part 2.
        {rhs, tokens} = parse_term(tokens, precedence)
        parse_op_expr({op, [lhs, rhs]}, tokens, precedence)
      [{:operator, :*} | tokens] ->
        # Handle * for part 2.
        {rhs, tokens} = parse_term(tokens, precedence)
        {rhs, tokens} = parse_op_expr(rhs, tokens, precedence)
        {{:*, [lhs, rhs]}, tokens}
    end
  end

  defp parse_term(tokens, precedence) do
    case tokens do
      [:lparen | tokens] ->
        {term, [:rparen | tokens]} = parse_expr(tokens, precedence)
        {term, tokens}
      [number | tokens] when is_number(number) ->
        {number, tokens}
    end
  end

  defp scan_expr(expr) do
    String.to_charlist(expr)
    |> Enum.map(&scan_char/1)
    |> Enum.filter(&(&1))
  end

  defp scan_char(char) do
    case char do
      ?* -> {:operator, :*}
      ?+ -> {:operator, :+}
      ?\( -> :lparen
      ?\) -> :rparen
      ?\s -> nil
      _ -> char - ?0
    end
  end
end
