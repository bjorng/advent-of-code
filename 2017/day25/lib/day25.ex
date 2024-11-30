defmodule Day25 do
  def part1(input) do
    {:ok, [machine], "", _, _, _} = TuringParser.turing(input)
    compiled_machine = TuringCompiler.compile(machine)
    compiled_machine.run()
  end
end

defmodule TuringCompiler do
  def compile({initial_state, steps, actions}) do
    ast = compile(initial_state, steps, actions)
    IO.puts(Macro.to_string(ast))
    [{module, _}] = Code.compile_quoted(ast, "CompiledTuringMachine")
    module
  end

  defp compile(initial_state, steps, actions) do
    quote do
      defmodule CompiledTuringMachine do
        # The architecture of the generated code is inspired by
        # https://ferd.ca/advent-of-code-2017.html.
        def run() do
          zipper = {[], [0]}
          run(unquote(initial_state), zipper, unquote(steps))
        end

        defp run(_, {prev, next}, 0) do
          Enum.sum(prev) + Enum.sum(next)
        end
        defp run(state, {prev, [current | next]}, steps) do
          case handle(state, current) do
            {current, :left, state} ->
              run(state, shift_left({prev, [current | next]}), steps - 1)
            {current, :right, state} ->
              run(state, shift_right({prev, [current | next]}), steps - 1)
          end
        end

        defp shift_left({[], next}), do: {[], [0 | next]}
        defp shift_left({[h | t], next}), do: {t, [h | next]}

        defp shift_right({prev, [h]}), do: {[h | prev], [0]}
        defp shift_right({prev, [h | t]}), do: {[h | prev], t}

        unquote_splicing(gen_handle_clauses(actions))
      end
    end
  end

  def gen_handle_clauses(actions) do
    for {{in_state, current_value}, action} <- actions do
      quote do
        defp handle(unquote(in_state), unquote(current_value)) do
          unquote(Macro.escape(action))
        end
      end
    end
  end
end

defmodule TuringParser do
  import NimbleParsec

  def head([state, steps]) do
    {String.to_atom(state), steps}
  end

  def state_definition([state, {value1, action1}, {value2, action2}]) do
    state = String.to_atom(state)
    [{{state, value1}, action1}, {{state, value2}, action2}]
  end

  def state_action([current, new_value, direction, new_state]) do
    {current, {new_value, String.to_atom(direction), String.to_atom(new_state)}}
  end

  def result([{initial_state, steps} | actions]) do
    {initial_state, steps , List.flatten(actions)}
  end

  blankspace = ignore(ascii_string([?\s], min: 1))

  head =
    ignore(string("Begin in state "))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(".\n"))
    |> ignore(string("Perform a diagnostic checksum after "))
    |> integer(min: 1)
    |> ignore(string(" steps.\n"))
    |> reduce({:head, []})

  state_head =
    ignore(string("\n"))
    |> ignore(string("In state "))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(":\n"))

  state_action =
    optional(blankspace)
    |> ignore(string("If the current value is "))
    |> integer(1)
    |> ignore(string(":\n"))
    |> optional(blankspace)
    |> ignore(string("- Write the value "))
    |> integer(1)
    |> ignore(string(".\n"))
    |> optional(blankspace)
    |> ignore(string("- Move one slot to the "))
    |> choice([string("left"), string("right")])
    |> ignore(string(".\n"))
    |> optional(blankspace)
    |> ignore(string("- Continue with state "))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(".\n"))
    |> reduce({:state_action, []})

  defcombinatorp :state_definition, state_head
  |> concat(state_action)
  |> concat(state_action)
  |> reduce({:state_definition, []})

  defcombinatorp(:state_definitions, repeat(parsec(:state_definition)))

  defparsec :turing, head
  |> parsec(:state_definitions)
  |> reduce({:result, []})
end
