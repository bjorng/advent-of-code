defmodule Day23 do
  def part1(input) do
    boot_nics(input) |> simple_nat
  end

  def part2(input) do
    boot_nics(input) |> nat
  end

  defp boot_nics(input) do
    0..49
    |> Enum.map(fn address ->
      nic = Intcode.new(input)
      Intcode.set_sink(nic, self())
      send(nic, [address])
      Intcode.go(nic)
      {address, nic}
    end)
    |> Map.new
  end

  defp simple_nat(nics) do
    receive do
      [255, _, y] ->
        y
      [to, x, y] ->
        send(Map.fetch!(nics, to), [x, y])
        simple_nat(nics)
      other ->
        other
    end
  end

  defp nat(nics, last \\ nil, last_idle \\ nil) do
    receive do
      [255, x, y] ->
        nat(nics, [x, y], last_idle)
      [to, x, y] ->
        send(Map.fetch!(nics, to), [x, y])
        nat(nics, last, last_idle)
    after 0 ->
        # Could be idle, but could be that some
        # NICs are still executing. Query all of them
        # to make sure.
        case all_idle?(nics) do
          true ->
            send(Map.fetch!(nics, 0), last)
            case {last, last_idle} do
              {[_, y], [_, y]} ->
                y
              {_, _} ->
                nat(nics, last, last)
            end
          false ->
            nat(nics, last, last_idle)
        end
    end
  end

  defp all_idle?(nics) do
    nics = Map.values(nics)
    Enum.each(nics, fn nic -> send(nic, {:is_idle, self()}) end)
    Enum.map(nics, fn _nic ->
      receive do
        {:idle, is_idle} -> is_idle
      end
    end)
    |> Enum.all?(& &1)
  end
end

defmodule Intcode do
  def new(program) do
    spawn(fn -> machine(program) end)
  end

  def set_sink(machine, sink) do
    send(machine, {:set_sink, sink})
  end

  def write_memory(machine, addr, val) do
    send(machine, {:write_memory, addr, val})
  end

  def go(machine) do
    send(machine, {:go, self()})
  end

  def terminate(machine) do
    send(machine, :terminate)
  end

  defp machine(input) do
    memory = read_program(input)
    memory = Map.put(memory, :output, [])
    memory = Map.put(memory, :input, :queue.new())
    memory = Map.put(memory, :is_idle, false)
    machine_loop(memory)
  end

  defp machine_loop(memory) do
    receive do
      {:set_sink, sink} ->
	memory = Map.put(memory, :sink, sink)
	machine_loop(memory)
      {:write_memory, addr, val} ->
	memory = write(memory, addr, val)
	machine_loop(memory)
      {:go, from} ->
	memory = execute(memory)
	send(from, {:halted, self()})
	machine_loop(memory)
      :terminate ->
	nil
    end
  end

  defp execute(memory, ip \\ 0) do
    {opcode, modes} = fetch_opcode(memory, ip)
    case opcode do
      1 ->
	memory = exec_arith_op(&+/2, modes, memory, ip)
	execute(memory, ip + 4)
      2 ->
	memory = exec_arith_op(&*/2, modes, memory, ip)
	execute(memory, ip + 4)
      3 ->
	memory = exec_input(modes, memory, ip)
	execute(memory, ip + 2)
      4 ->
	memory = exec_output(modes, memory, ip)
	execute(memory, ip + 2)
      5 ->
	ip = exec_if(&(&1 !== 0), modes, memory, ip)
	execute(memory, ip)
      6 ->
	ip = exec_if(&(&1 === 0), modes, memory, ip)
	execute(memory, ip)
      7 ->
	memory = exec_cond(&(&1 < &2), modes, memory, ip)
	execute(memory, ip + 4)
      8 ->
	memory = exec_cond(&(&1 === &2), modes, memory, ip)
	execute(memory, ip + 4)
      9 ->
	memory = exec_inc_rel_base(modes, memory, ip)
	execute(memory, ip + 2)
      99 ->
	memory
    end
  end

  defp exec_arith_op(op, modes, memory, ip) do
    [in1, in2] = read_operand_values(memory, ip + 1, modes, 2)
    out_addr = read_out_address(memory, div(modes, 100), ip + 3)
    result = op.(in1, in2)
    write(memory, out_addr, result)
  end

  defp exec_input(modes, memory, ip) do
    out_addr = read_out_address(memory, modes, ip + 1)
    q = Map.fetch!(memory, :input)
    q = fill_queue(q, memory.is_idle)
    case :queue.out(q) do
      {{:value, value}, q} ->
        memory = write(memory, out_addr, value)
        %{memory | input: q, is_idle: false}
      {:empty, q} ->
        memory = write(memory, out_addr, -1)
        %{memory | input: q, is_idle: true}
    end
  end

  defp fill_queue(q, is_idle) do
    receive do
      [_ | _] = input ->
        q = Enum.reduce(input, q, & :queue.in(&1, &2))
        fill_queue(q, is_idle)
      {:is_idle, reply_to} ->
        send(reply_to, {:idle, :queue.is_empty(q) and is_idle})
        fill_queue(q, is_idle)
    after 0 ->
        q
    end
  end

  defp exec_output(modes, memory, ip) do
    [value] = read_operand_values(memory, ip + 1, modes, 1)
    case memory do
      %{:output => [b, a]} ->
        sink = Map.fetch!(memory, :sink)
        send(sink, [a, b, value])
        %{memory | output: [], is_idle: false }
      %{:output => output} ->
        %{memory | output: [value | output], is_idle: false}
    end
  end

  defp exec_if(op, modes, memory, ip) do
    [value, new_ip] = read_operand_values(memory, ip + 1, modes, 2)
    case op.(value) do
      true -> new_ip
      false -> ip + 3
    end
  end

  defp exec_cond(op, modes, memory, ip) do
    [operand1, operand2] = read_operand_values(memory, ip + 1, modes, 2)
    out_addr = read_out_address(memory, div(modes, 100), ip + 3)
    result = case op.(operand1, operand2) do
	       true -> 1
	       false -> 0
	     end
    write(memory, out_addr, result)
  end

  defp exec_inc_rel_base(modes, memory, ip) do
    [offset] = read_operand_values(memory, ip + 1, modes, 1)
    base = get_rel_base(memory) + offset
    Map.put(memory, :rel_base, base)
  end

  defp read_operand_values(_memory, _addr, _modes, 0), do: []
  defp read_operand_values(memory, addr, modes, n) do
    operand = read(memory, addr)
    operand = case rem(modes, 10) do
		0 -> read(memory, operand)
		1 -> operand
		2 -> read(memory, operand + get_rel_base(memory))
	      end
    [operand | read_operand_values(memory, addr + 1, div(modes, 10), n - 1)]
  end

  defp read_out_address(memory, modes, addr) do
    out_addr = read(memory, addr)
    case modes do
      0 -> out_addr
      2 -> get_rel_base(memory) + out_addr
    end
  end

  defp fetch_opcode(memory, ip) do
    opcode = read(memory, ip)
    modes = div(opcode, 100)
    opcode = rem(opcode, 100)
    {opcode, modes}
  end

  defp get_rel_base(memory) do
    Map.get(memory, :rel_base, 0)
  end

  defp read(memory, addr) do
    Map.get(memory, addr, 0)
  end

  defp write(memory, addr, value) do
    Map.put(memory, addr, value)
  end

  defp read_program(input) do
    String.split(input, ",")
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index
    |> Stream.map(fn {code, index} -> {index, code} end)
    |> Map.new
  end
end
