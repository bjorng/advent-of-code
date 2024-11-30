defmodule Day21 do
  use Bitwise

  @moduledoc """

  This module only solves the problem for my input data.
  My input and the solutions can be found in test/day21_test.exs.

  I solved part one by first examining the assembly program.
  It quickly became apparent that register 0 (A) must be set
  equal to the value of F at address 0028. I turned on instruction
  trace and could see the solution directly in the trace.

  For part 2, I installed two breakpoint handlers. The first one
  at address 0017 optimizes the inner loop. The second one at
  address 0028 remembers all possible results that have been
  seen so far. When a value is seen for the second time, the
  same sequence of values will repeat forever. The result is the
  value *before* the first repeated value. (It turns out that
  there are 11669 distinct values before the cycle repeats itself.)

  For reference, here is my input program prettified:

  0000  F = 123

  0001  F = F band 456
  0002  F = F == 72
  0003  IP = IP + F
  0004  goto 1

  0005  F = 0

  0006  B = F bor 65536
  0007  F = 4591209

  0008  D = B band 255
  0009  F = F + D
  0010  F = F band 16777215
  0011  F = F * 65899
  0012  F = F band 16777215
  0013  D = 256 > B
  0014  IP = IP + D
  0015  IP = IP + 1
  0016  goto 28

  0017  D = 0

  0018  C = D + 1
  0019  C = C * 256
  0020  C = C > B
  0021  IP = IP + C
  0022  IP = IP + 1
  0023  goto 26

  0024  D = D + 1
  0025  goto 18

  0026  B = D
  0027  goto 8

  0028  D = F == A
  0029  IP = IP + D
  0030  goto 6
  """

  def decompile_program lines do
    {ip_reg, program} = parse_program lines
    machine = Machine.new(program, 6, ip_reg)
    Machine.decompile_program machine
  end

  def part1 lines, initial_r0, trace \\ false do
    {ip_reg, program} = parse_program lines
    machine = Machine.new(program, 6, ip_reg, trace)
    machine = Machine.set_reg(machine, 0, initial_r0)
    machine = Machine.set_breakpoint machine, 17, &optimize_bp/1
    machine = Machine.execute_program machine
    elem(machine.regs, 0)
  end

  def part2 lines do
    {ip_reg, program} = parse_program lines
    machine = Machine.new program, 6, ip_reg
    machine = Machine.set_breakpoint machine, 17, &optimize_bp/1
    machine = Machine.set_breakpoint machine, 28, &result_bp/1
    machine = Map.put(machine, :seen, MapSet.new())
    machine = Map.put(machine, :result, nil)
    machine = Machine.execute_program machine
    #IO.inspect MapSet.size(machine.seen)
    machine.result
  end

  # Breakpoint handler to optimize the inner loop that
  # is entered at address 17.

  defp optimize_bp(machine) do
    %{regs: regs} = machine
    b = elem(regs, 1)
    d = max(0, div(b, 256) - 1)
    regs = put_elem(regs, 3, d)
    %{machine | regs: regs, ip: 18}
  end

  # Breakpoint handler to examine the values that can
  # make the program halt.

  defp result_bp(machine) do
    %{regs: regs, seen: seen} = machine
    result = elem(regs, 5)
    if MapSet.member?(seen, result) do
      # We have seen this result before. That means that
      # possible values will begin to repeat from here.
      # Done.
      Map.put(machine, :ip, 999)
    else
      # Save this potential result and continue executing.
      %{machine | ip: 6, result: result,
        seen: MapSet.put(seen, result)}
    end
  end

  defp parse_program [first | lines] do
    <<"#ip ", ip_reg>> = first
    ip_reg = ip_reg - ?0
    {ip_reg, Enum.map(lines, &parse_instr/1)}
  end

  defp parse_instr line do
    [opcode | operands] = String.split(line, " ")
    opcode = String.to_atom(opcode)
    operands = Enum.map(operands, &String.to_integer/1)
    {{opcode, Keyword.get(Machine.instructions, opcode)}, operands}
  end
end

defmodule Machine do
  use Bitwise

  def new program, num_registers, ip_reg, trace \\ false do
    program = program
    |> Enum.with_index
    |> Enum.map(fn {instr, ip} -> {ip, instr} end)
    |> Map.new
    regs = :erlang.make_tuple(num_registers, 0)
    %{ip: 0, regs: regs, ip_reg: ip_reg,
      program: program, breakpoints: %{},
      trace: trace}
  end

  def set_reg machine, reg, value do
    regs = put_elem machine.regs, reg, value
    put_in machine.regs, regs
  end

  def set_breakpoint(machine, ip, fun) when is_function(fun, 1) do
    breakpoints = Map.put(machine.breakpoints, ip, fun)
    put_in machine.breakpoints, breakpoints
  end

  def execute_program machine do
    %{ip: ip, program: program, ip_reg: ip_reg, regs: regs0,
      breakpoints: breakpoints, trace: trace} = machine
    case program do
      %{^ip => {{_, execute}, operands} = instr} ->
	regs0 = put_elem regs0, ip_reg, ip
	case breakpoints do
	  %{^ip => breakpoint} ->
	    machine = Map.put(machine, :regs, regs0)
	    machine = breakpoint.(machine)
	    execute_program machine
	  %{} ->
	    regs = execute.(operands, regs0)
	    if trace do
              :io.format('~4..0w ~-50s ~-22s ~s\n',
		[ip, pp_regs(regs0), decompile_instr(instr, ip_reg, ip), pp_regs(regs)])
              if elem(regs0, ip_reg) != elem(regs, ip_reg) do
                IO.puts ""
              end
	    end
	    ip = elem(regs, ip_reg)
	    ip = ip + 1
	    machine = %{machine | ip: ip, regs: regs}
	    execute_program machine
	end
      %{} ->
        machine
    end
  end

  defp pp_regs regs do
    Tuple.to_list(regs)
    |> Stream.with_index
    |> Enum.map(fn {value, index} -> [index + ?A, '=' | int_to_str(value)] end)
    |> Enum.intersperse(' ')
  end

  def decompile_program machine do
    %{program: program, ip_reg: ip_reg} = machine
    IO.puts ""
    program
    |> Enum.sort
    |> Enum.each(fn {ip, instr} ->
      str = decompile_instr(instr, ip_reg, ip)
      :io.format("~4..0w  ~s\n", [ip, str])
    end)
  end

  defp decompile_instr({{name, _}, operands}, ip_reg, _ip) do
    {op, result, sources} = translate_instr name, operands, ip_reg
    case op do
      'set' ->
        [result, ' = ', hd(sources)]
      'goto' ->
        ['goto ', hd(sources)]
      _ ->
        op = case op do
               'ban' -> 'band'
               'bo' -> 'bor'
               'eq' -> '=='
               'gt' -> '>'
               'add' -> '+'
               'mul' -> '*'
               _ -> op
             end
        {src1, src2} = case sources do
                         [other, 'IP'] -> {'IP', other}
                         [src1, src2] -> {src1, src2}
                       end
        [result, ' = ', src1, ' ', op, ' ', src2]
    end
  end

  defp translate_instr(name, [src1, src2, result], ip_reg) do
    [c1, c2, c3, _c4] = name = Atom.to_charlist(name)
    op = [c1, c2, c3]
    result = translate_reg(result, ip_reg)
    case name do
      'seti' when result == 'IP' ->
        {'goto', result, [int_to_str(src1 + 1)]}
      'seti' ->
        {op, result, [int_to_str(src1)]}
      'setr' ->
        {op, result, [translate_reg(src1, ip_reg)]}
      [_, _, ?i, ?i] ->
        {[c1, c2], result, [int_to_str(src1), int_to_str(src2)]}
      [_, _, ?i, ?r] ->
        {[c1, c2], result, [int_to_str(src1), translate_reg(src2, ip_reg)]}
      [_, _, ?r, ?r] ->
        {[c1, c2], result, [translate_reg(src1, ip_reg), translate_reg(src2, ip_reg)]}
      [_, _, ?r, ?i] ->
        {[c1, c2], result, [translate_reg(src1, ip_reg), int_to_str(src2)]}
      [_, _, _, ?i] ->
        {op, result, [translate_reg(src1, ip_reg), int_to_str(src2)]}
      [_, _, _, ?r] ->
        {op, result, [translate_reg(src1, ip_reg), translate_reg(src2, ip_reg)]}
    end
  end

  defp int_to_str(int), do: Integer.to_charlist(int)

  defp translate_reg(ip_reg, ip_reg), do: 'IP'
  defp translate_reg(reg, _), do: [reg + ?A]

  def instructions do
    [{:addr, &addr/2},
     {:addi, &addi/2},
     {:mulr, &mulr/2},
     {:muli, &muli/2},
     {:banr, &banr/2},
     {:bani, &bani/2},
     {:borr, &borr/2},
     {:bori, &bori/2},
     {:setr, &setr/2},
     {:seti, &seti/2},
     {:gtir, &gtir/2},
     {:gtri, &gtri/2},
     {:gtrr, &gtrr/2},
     {:eqir, &eqir/2},
     {:eqri, &eqri/2},
     {:eqrr, &eqrr/2}]
  end

  @doc """
  addr (add register) stores into register C the result of
  adding register A and register B.

  ## Examples

      iex> Machine.addr [1, 2, 0], {1, 4, 5, 10, 177, 178}
      {9, 4, 5, 10, 177, 178}

  """

  def addr [a, b, c], regs do
    put_elem regs, c, elem(regs, a) + elem(regs, b)
  end

  @doc """
  addi (add immediate) stores into register C the result of adding
  register A and value B.


  ## Examples

      iex> Machine.addi [1, 42, 3], {1, 4, 5, 10, 177, 178}
      {1, 4, 5, 46, 177, 178}

  """

  def addi [a, b, c], regs do
    put_elem regs, c, elem(regs, a) + b
  end

  @doc """
  mulr (multiply register) stores into register C the result of
  multiplying register A and register B.

  ## Examples

      iex> Machine.mulr [1, 2, 0], {1, 4, 5, 10, 177, 178}
      {20, 4, 5, 10, 177, 178}

  """

  def mulr [a, b, c], regs do
    put_elem regs, c, elem(regs, a) * elem(regs, b)
  end

  @doc """
  muli (multiply immediate) stores into register C the result of multiplying
  register A and value B.


  ## Examples

      iex> Machine.muli [1, 42, 3], {1, 4, 5, 10, 177, 178}
      {1, 4, 5, 168, 177, 178}

  """

  def muli [a, b, c], regs do
    put_elem regs, c, elem(regs, a) * b
  end

  @doc """
  banr (bitwise AND register) stores into register C the result of the
  bitwise AND of register A and register B.

  ## Examples

      iex> Machine.banr [1, 2, 0], {1, 5, 13, 10, 177, 178}
      {5, 5, 13, 10, 177, 178}

  """

  def banr [a, b, c], regs do
    put_elem regs, c, band(elem(regs, a), elem(regs, b))
  end

  @doc """
  bani (bitwise AND immediate) stores into register C the result of
  the bitwise AND of register A and value B.

  ## Examples

      iex> Machine.bani [3, 8, 0], {1, 4, 5, 10, 177, 178}
      {8, 4, 5, 10, 177, 178}

  """

  def bani [a, b, c], regs do
    put_elem regs, c, band(elem(regs, a), b)
  end

  @doc """
  borr (bitwise OR register) stores into register C the result of
  the bitwise OR of register A and register B.

  ## Examples

      iex> Machine.borr [1, 2, 0], {1, 5, 9, 10, 177, 178}
      {13, 5, 9, 10, 177, 178}

  """

  def borr [a, b, c], regs do
    put_elem regs, c, bor(elem(regs, a), elem(regs, b))
  end

  @doc """
  bori (bitwise OR immediate) stores into register C the result of
  the bitwise OR of register A and value B.

  ## Examples

      iex> Machine.bori [3, 32, 0], {1, 4, 5, 10, 177, 178}
      {42, 4, 5, 10, 177, 178}

  """

  def bori [a, b, c], regs do
    put_elem regs, c, bor(elem(regs, a), b)
  end

  @doc """
  setr (set register) copies the contents of register A into register C.
  (Input B is ignored.)

  ## Examples

      iex> Machine.setr [3, 999, 1], {1, 4, 5, 10, 177, 178}
      {1, 10, 5, 10, 177, 178}

  """

  def setr [a, _b, c], regs do
    put_elem regs, c, elem(regs, a)
  end

  @doc """
  seti (set immediate) stores value A into register C. (Input B is ignored.)

  ## Examples

      iex> Machine.seti [777, 999, 0], {1, 4, 5, 10, 177, 178}
      {777, 4, 5, 10, 177, 178}

  """

  def seti [a, _b, c], regs do
    put_elem regs, c, a
  end

  @doc """
  gtir (greater-than immediate/register) sets register C to 1 if value A
  is greater than register B. Otherwise, register C is set to 0.


  ## Examples

      iex> Machine.gtir [7, 2, 0], {1, 4, 5, 10, 177, 178}
      {1, 4, 5, 10, 177, 178}
      iex> Machine.gtir [0, 2, 0], {1, 4, 5, 10, 177, 178}
      {0, 4, 5, 10, 177, 178}

  """

  def gtir [a, b, c], regs do
    put_bool regs, c, a > elem(regs, b)
  end

  @doc """
  gtri (greater-than register/immediate) sets register C to 1 if register A
  is greater than value B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.gtri [3, 9, 0], {1, 4, 5, 10, 177, 178}
      {1, 4, 5, 10, 177, 178}
      iex> Machine.gtri [2, 9, 0], {1, 4, 5, 10, 177, 178}
      {0, 4, 5, 10, 177, 178}

  """

  def gtri [a, b, c], regs do
    put_bool regs, c, elem(regs, a) > b
  end

  @doc """
  gtrr (greater-than register/register) sets register C to 1 if register A
  is greater than register B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.gtrr [3, 2, 0], {1, 4, 5, 10, 177, 178}
      {1, 4, 5, 10, 177, 178}
      iex> Machine.gtrr [1, 2, 0], {1, 4, 5, 10, 177, 178}
      {0, 4, 5, 10, 177, 178}

  """

  def gtrr [a, b, c], regs do
    put_bool regs, c, elem(regs, a) > elem(regs, b)
  end

  @doc """
  eqir (equal immediate/register) sets register C to 1 if value A is
  equal to register B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.eqir [4, 1, 0], {1, 4, 5, 10, 177, 178}
      {1, 4, 5, 10, 177, 178}
      iex> Machine.eqir [42, 1, 0], {1, 4, 5, 10, 177, 178}
      {0, 4, 5, 10, 177, 178}

  """

  def eqir [a, b, c], regs do
    put_bool regs, c, a == elem(regs, b)
  end

  @doc """
  eqri (equal register/immediate) sets register C to 1 if register A
  is equal to value B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.eqri [3, 10, 0], {1, 4, 5, 10, 177, 178}
      {1, 4, 5, 10, 177, 178}
      iex> Machine.eqri [3, 19, 0], {1, 4, 5, 10, 177, 178}
      {0, 4, 5, 10, 177, 178}

  """

  def eqri [a, b, c], regs do
    put_bool regs, c, elem(regs, a) == b
  end

  @doc """
  eqrr (equal register/register) sets register C to 1 if register A
  is equal to register B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.eqrr [3, 2, 0], {1, 4, 5, 10, 177, 178}
      {0, 4, 5, 10, 177, 178}
      iex> Machine.eqrr [3, 2, 0], {1, 4, 10, 10, 177, 178}
      {1, 4, 10, 10, 177, 178}

  """

  def eqrr [a, b, c], regs do
    put_bool regs, c, elem(regs, a) == elem(regs, b)
  end

  defp put_bool regs, c, bool do
    bool = if bool, do: 1, else: 0
    put_elem regs, c, bool
  end
end
