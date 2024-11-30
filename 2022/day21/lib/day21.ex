defmodule Day21 do
  def part1(input) do
    equations = parse(input)
    |> Map.new
    simplify(Map.fetch!(equations, :root), equations)
  end

  def part2(input) do
    parse(input)
    equations = parse(input)
    |> Map.new
    equations = Map.delete(equations, :humn)
    {_, lhs, rhs} = Map.fetch!(equations, :root)
    lhs = simplify(lhs, equations)
    rhs = simplify(rhs, equations)
    if is_integer(lhs) do
      solve(rhs, lhs)
    else
      solve(lhs, rhs)
    end
  end

  defp simplify(expr, equations) do
    case expr do
      {operator, lhs, rhs} ->
        case {simplify(lhs, equations), simplify(rhs, equations)} do
          {lhs, rhs} when is_integer(lhs) and is_integer(rhs) ->
            apply(:erlang, operator, [lhs, rhs])
          {lhs, rhs} ->
            {operator, lhs, rhs}
        end
      _ ->
        case equations do
          %{^expr => expr} ->
            simplify(expr, equations)
          %{} ->
            expr
        end
    end
  end

  defp solve(equation, must_be) when is_integer(must_be) do
    case equation do
      {:div, equation, value} when is_integer(value) ->
        solve(equation, value * must_be)
      {:+, equation, value} when is_integer(value) ->
        solve(equation, must_be - value)
      {:+, value, equation} when is_integer(value) ->
        solve({:+, equation, value}, must_be)
      {:-, equation, value} when is_integer(value) ->
        solve(equation, must_be + value)
      {:-, value, equation} when is_integer(value) ->
        solve(equation, value - must_be)
      {:*, equation, value} when is_integer(value) ->
        solve(equation, div(must_be, value))
      {:*, value, equation} when is_integer(value) ->
        solve({:*, equation, value}, must_be)
      :humn ->
        must_be
    end
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      [monkey, rest] = String.split(line, ": ")
      expr = case String.split(rest, " ") do
               [lhs, operator, rhs] ->
                 operator = case String.to_atom(operator) do
                              :/ -> :div
                              operator -> operator
                            end
                 {operator,
                  parse_operand(lhs),
                  parse_operand(rhs)}
               [operand] ->
                 parse_operand(operand)
             end
      {String.to_atom(monkey), expr}
    end)
  end

  defp parse_operand(operand) do
    case Integer.parse(operand) do
      {integer, ""} ->
        integer
      :error ->
        String.to_atom(operand)
    end
  end
end
