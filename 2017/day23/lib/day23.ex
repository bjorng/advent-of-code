defmodule Day23 do
  def part1(input) do
    Machine.new(input, true)
    |> Machine.execute
    |> Machine.get_instr_count(:mul)
  end

  def part2(_input) do
    # As an estimate, running the optimized input
    # (see the source in CompiledMachine) would take
    # about 3 hours on my computer.
    #
    # Running the optimized input translated to Elixir
    # code using MachineCompiler takes about two minutes.
    CompiledMachine.run
  end
end

defmodule Machine do
  def new(program, debug) do
    program
    |> Stream.with_index
    |> Enum.into(%{}, fn {instr, addr} ->
      [op | operands] = String.split(instr, " ")
      op = String.to_atom(op)
      operands = Enum.map(operands, fn operand ->
        case Integer.parse(operand) do
          :error ->
            String.to_atom(operand)
          {int, ""} ->
            int
        end
      end)
      {addr, List.to_tuple([op | operands])}
    end)
    |> init_machine(debug)
  end

  defp init_machine(machine, debug) do
    case debug do
      true -> [{:counts, %{}}]
      false -> [{:a, 1}]
    end
    |> Enum.into(machine)
  end

  def get_instr_count(machine, op) do
    machine.counts[op]
  end

  def get_reg(machine, reg) do
    machine[reg]
  end

  def resume(machine) do
    case Map.get(machine, :ip, nil) do
      nil ->
        machine
      ip ->
        execute(machine, ip)
    end
  end

  def execute(machine, ip \\ 0) do
    case Map.get(machine, ip, nil) do
      nil ->
        Map.delete(machine, :ip)
      instr ->
        case machine do
          %{:counts => counts} ->
            op = elem(instr, 0)
            counts = Map.update(counts, op, 1, & &1 + 1)
            machine = Map.put(machine, :counts, counts)
            execute_instr(instr, machine, ip)
          %{} ->
            execute_instr(instr, machine, ip)
        end
    end
  end

  defp execute_instr(instr, machine, ip) do
    case instr do
      {:set, dst, src} ->
        machine = set_value(machine, dst, get_value(machine, src))
        execute(machine, ip + 1)
      {:sub, dst, src} ->
        execute_arith_op(machine, ip, dst, src, &-/2)
      {:mul, dst, src} ->
        execute_arith_op(machine, ip, dst, src, &*/2)
      {:jnz, src, offset} ->
        case get_value(machine, src) do
          0 ->
            execute(machine, ip + 1)
          _ ->
            execute(machine, ip + get_value(machine, offset))
        end
    end
  end

  defp execute_arith_op(machine, ip, dst, src, op) do
    value = op.(get_value(machine, dst), get_value(machine, src))
    machine = set_value(machine, dst, value)
    execute(machine, ip + 1)
  end

  defp get_value(machine, value) do
    cond do
      is_integer(value) -> value
      is_atom(value) -> Map.get(machine, value, 0)
    end
  end

  defp set_value(machine, register, value) when is_atom(register) do
    Map.put(machine, register, value)
  end
end

defmodule MachineCompiler do
  defmacro compile(program) do
    {program, []} = Code.eval_quoted(program)
    quote do
      unquote(gen_clauses(program))
      defp result(a, b, c, d, e, f, g, h), do: h

      def run() do
        run0(1, 0, 0, 0, 0, 0, 0, 0)
      end
    end
  end

  defp gen_clauses(program) do
    for {head, body} <- do_compile(program) do
      IO.write "#{Macro.to_string({:defp, [], [head, [{:do, body}]]})}\n"
      quote do: defp unquote(head), do: unquote(body)
    end
  end

  defp do_compile(program) do
    parse_program(program)
    |> absolutify
    |> basic_blocks
    |> renumber
    |> translate_bbs
  end

  defp absolutify(program) do
    Enum.map(program, fn {addr, instr} ->
      instr = case instr do
                {:jnz, value, offset} ->
                  false_target = shortcut_jump(addr + 1, program)
                  true_target = shortcut_jump(addr + offset, program)
                  {:jnz, value, false_target, true_target}
                _ ->
                  instr
              end
      {addr, instr}
    end)
  end

  defp shortcut_jump(target, program) do
    case Enum.find(program, fn {addr, _} -> addr === target end) do
      {_, {:jnz, 1, offset}} ->
        shortcut_jump(target + offset, program)
      _ ->
        target
    end
  end

  defp basic_blocks(program) do
    reachable = Enum.reduce(program, [], fn {_addr, instr}, acc ->
      case instr do
        {:jnz, 1, _, true_target} ->
          [true_target | acc]
        {:jnz, _, false_target, true_target} ->
          [false_target, true_target | acc]
        _ ->
          acc
      end
    end)
    |> MapSet.new
    Enum.map_reduce(program, 0, fn {addr, instr} = pair, id ->
      case {instr, MapSet.member?(reachable, addr)} do
        {{:jnz, _, _, _}, _} ->
          {{pair, id}, id + 1}
        {_, true} ->
          {{pair, id + 1}, id + 1}
        {_, _} ->
          {{pair, id}, id}
      end
    end)
    |> elem(0)
    |> Enum.chunk_by(fn {_, chunk_id} -> chunk_id end)
    |> Enum.map(fn chunk ->
      Enum.map(chunk, fn {pair, _} -> pair end)
    end)
  end

  defp renumber(program) do
    map = Enum.with_index(program)
    |> Enum.into(%{}, fn {[{addr, _} | _], index} ->
      {addr, String.to_atom("run" <> to_string(index))}
    end)
    Enum.map(program, fn bb ->
      Enum.map(bb, fn {addr, instr} ->
        instr = case instr do
                  {:jnz, value, false_target, true_target} ->
                    {:jnz, value,
                     Map.get(map, false_target, :result),
                     Map.get(map, true_target, :result)}
                  _ ->
                    instr
                end
        case map do
          %{^addr => new_addr} ->
            {new_addr, instr}
          %{} ->
            {nil, instr}
        end
      end)
    end)
  end

  defp translate_bbs([bb | bbs]) do
    next = quote do: unquote(call_run(find_next(bbs)))
    [translate_bb(bb, next) | translate_bbs(bbs)]
  end
  defp translate_bbs([]), do: []

  defp translate_bb([{name, _instr} | _] = instrs, next) do
    instrs = translate_instrs(instrs, next)
    {head(name), make_block(instrs)}
  end

  defp find_next([[{name, _} | _] | _]), do: name
  defp find_next(_), do: :result

  defp translate_instrs([{_addr, instr}], next) do
    case translate_instr(instr) do
      {instr, true} ->
        instr ++ [next]
      {instr, false} ->
        instr
    end
  end
  defp translate_instrs([{_addr, instr} | instrs], next) do
    instrs = translate_instrs(instrs, next)
    {instr, _} = translate_instr(instr)
    instr ++ instrs
  end

  defp translate_instr({:set, dst, src}) do
    set = quote do: unquote(value(dst)) = unquote(value(src))
    {[set], true}
  end
  defp translate_instr({:mul, dst, src}) do
    dst = value(dst)
    src = value(src)
    op = quote do: unquote(dst) = unquote(dst) * unquote(src)
    {[op], true}
  end
  defp translate_instr({:sub, :h, src}) do
    set = quote do: h = h - unquote(value(src))
    debug = quote do: IO.write "#{d} * #{e} = #{b}\n"
    {[set, debug], true}
  end
  defp translate_instr({:sub, dst, src}) do
    dst = value(dst)
    src = value(src)
    op = if is_integer(src) and src < 0 do
      # The BEAM loader optimizes an addition of a constant better
      # than a subtraction of a constant.
      quote do: unquote(dst) = unquote(dst) + unquote(-src)
    else
      quote do: unquote(dst) = unquote(dst) - unquote(src)
    end
    {[op], true}
  end
  defp translate_instr({:jnz, src, false_target, true_target}) do
    instr = quote do
        if unquote(value(src)) === 0 do
          unquote(call_run(false_target))
        else
          unquote(call_run(true_target))
        end
    end
    {[instr], false}
  end

  defp make_block(qs) do
    {:__block__, [], qs}
  end

  defp head(name) do
    quote do: unquote(name)(a, b, c, d, e, f, g, h)
  end

  defp call_run(name) do
    head(name)
  end

  defp value(int) when is_integer(int), do: int
  defp value(var) when is_atom(var), do: Macro.var(var, __MODULE__)

  defp parse_program(program) do
    program
    |> Stream.with_index
    |> Enum.map(fn {instr, addr} ->
      instr = Regex.replace(~r/\s*\#.*/, instr, "")
      [op | operands] = String.split(instr, " ")
      op = String.to_atom(op)
      operands = Enum.map(operands, fn operand ->
        case Integer.parse(operand) do
          :error ->
            String.to_atom(operand)
          {int, ""} ->
            int
        end
      end)
      {addr, List.to_tuple([op | operands])}
    end)
  end
end

defmodule CompiledMachine do
  import MachineCompiler

  # The original program is a very inefficient way to
  # count the number of composite numbers in the sequence:
  #
  #  109300, 109300 + 17, 109300 + 2*17, ..., 126300
  #
  # To determine whether a number b in the sequence is a composite
  # number, the program multiplies all combinations of factors from 2
  # up to b - 1 (using the d and e registers). If the product of the
  # two factors are equal to b, a flag (f) is set to indicate that b
  # is composite, but all remaining combinations of factors will be
  # tried.
  #
  # That makes the complexity O(b^2).
  #
  # In the program below, the instruction "sub g b" was changed to
  # "sub g 356". That will limit the trial factor in e to the square
  # root of the upper limit (if a number is composite, at least one
  # factor must be less or equal to the square root of the number).
  #
  # That change alone lowers the complexity to O(b).
  #
  # The other change was to change "set f 1" to "jnz 1 10": When a
  # number has been found to be composite, immediately jump to the
  # code that updates the counter for the number of composite numbers
  # found and starts testing the next number in the sequence.
  """
  set b 93
  set c b
  jnz a 2
  jnz 1 5
  mul b 100
  sub b -100000
  set c b
  sub c -17000
  set f 1
  set d 2
  set e 2
  set g d
  mul g e
  sub g b
  jnz g 2
  jnz 1 10   # Was "set f 1".
  sub e -1
  set g e
  sub g 357  # Was "sub g b".
  jnz g -8
  sub d -1
  set g d
  sub g b
  jnz g -13
  jnz f 2
  sub h -1
  set g b
  sub g c
  jnz g 2
  jnz 1 3
  sub b -17
  jnz 1 -23
  """
  |> String.split("\n", trim: true)
  |> compile
end
