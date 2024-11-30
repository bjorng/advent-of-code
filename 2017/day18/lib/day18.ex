defmodule Day18 do
  def part1(input) do
    Machine.new(input)
    |> Machine.execute
    |> Machine.get_output
    |> elem(0)
    |> List.last
  end

  def part2(input) do
    machine0 = Machine.new(input, 0)
    machine1 = Machine.new(input, 1)
    machine0 = Machine.execute(machine0)
    machine1 = Machine.execute(machine1)
    machines = Enum.into([{0, machine0}, {1, machine1}], %{})
    run_until_deadlock(machines)
  end

  defp run_until_deadlock(machines, num_sends \\ 0) do
    new_sends = Map.fetch!(machines, 1)
    |> Machine.get_output
    |> elem(0)
    |> length
    num_sends = num_sends + new_sends

    machines = do_io(machines)
    case all_terminated?(machines) or no_input?(machines) do
      true ->
        num_sends
      false ->
        machines = resume_all(machines)
        run_until_deadlock(machines, num_sends)
    end
  end

  defp do_io(machines) do
    Enum.reduce(machines, machines, fn {id, _}, acc ->
      other_id = rem(id + 1, 2)
      %{^id => machine, ^other_id => other_machine} = acc
      {output, machine} = Machine.get_output(machine)
      other_machine = Machine.push_input(other_machine, output)
      %{acc | id => machine, other_id => other_machine}
    end)
  end

  defp all_terminated?(machines) do
    Enum.all?(machines, fn {_, machine} ->
      Machine.terminated?(machine)
    end)
  end

  defp no_input?(machines) do
    Enum.all?(machines, fn {_, machine} ->
      Machine.no_input?(machine)
    end)
  end

  defp resume_all(machines) do
    Enum.into(machines, %{}, fn {id, machine} ->
      {id, Machine.resume(machine)}
    end)
  end
end

defmodule Machine do
  def new(program, id \\ 0) do
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
    |> init_machine(id)
  end

  defp init_machine(machine, id) do
    q = :queue.new()
    [{:p, id}, {:input, q}, {:output, q}]
    |> Enum.into(machine)
  end

  def push_input(machine, input) do
    q = Enum.reduce(input, machine.input, fn char, q ->
      :queue.in(char, q)
    end)
    Map.put(machine, :input, q)
  end

  def no_input?(machine) do
    :queue.is_empty(machine.input)
  end

  def get_output(machine) do
    output = :queue.to_list(machine.output)
    machine = %{machine | output: :queue.new()}
    {output, machine}
  end

  def terminated?(machine) do
    Map.get(machine, :ip, nil) == nil
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
      {:snd, val} ->
        val = get_value(machine, val)
        output = Map.fetch!(machine, :output)
        output = :queue.in(val, output)
        machine = Map.put(machine, :output, output)
        execute(machine, ip + 1)
      {:set, dst, src} ->
        machine = set_value(machine, dst, get_value(machine, src))
        execute(machine, ip + 1)
      {:add, dst, src} ->
        execute_arith_op(machine, ip, dst, src, &+/2)
      {:mul, dst, src} ->
        execute_arith_op(machine, ip, dst, src, &*/2)
      {:mod, dst, src} ->
        execute_arith_op(machine, ip, dst, src, &modulo/2)
      {:rcv, dst} ->
        input = Map.fetch!(machine, :input)
        case :queue.out(input) do
          {:empty, _} ->
            Map.put(machine, :ip, ip)
          {{:value, value}, input} ->
            machine = set_value(machine, dst, value)
            machine = Map.put(machine, :input, input)
            execute(machine, ip + 1)
        end
      {:jgz, src, offset} ->
        if get_value(machine, src) > 0 do
          execute(machine, ip + get_value(machine, offset))
        else
          execute(machine, ip + 1)
        end
    end
  end

  defp modulo(n, m) do
    case rem(n, m) do
      mod when mod >= 0 -> mod
      mod -> mod + m
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
