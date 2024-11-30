#
# This is not a general solution for any input, unless you are willing
# to wait a very long time for it to finish part 2. This solution solves
# part 2 for *my* input in less than 20 seconds.
#
# I wrote a general mechanism for installing a breakpoint handler.
# I then wrote a specific breakpoint handler that optimizes the inner
# loop for my input.
#
# The breakpoint handler will only be installed if the input program
# is *similar* to the program in my input. Similar means that it must
# use the same instructions in the same order, but it could use other
# registers.  If the inner loop is not similar, the breakpoint handler
# will not be installed.
#

defmodule Day19 do
  def part1 lines, trace \\ false do
    {ip_reg, program} = parse_program lines
    machine = Machine.new(program, 6, ip_reg, trace)
    machine = optimize(machine)
    Machine.print_program machine
    Machine.execute_program machine
  end

  def part2 lines, trace \\ false do
    {ip_reg, program} = parse_program lines
    machine = Machine.new(program, 6, ip_reg, trace)
    machine = Machine.set_reg machine, 0, 1
    machine = optimize(machine)
    Machine.execute_program machine
  end

  # Try to install the breakpoint handler to optimize the running
  # of the inner loop.
  defp optimize machine do
    %{program: program, ip_reg: ip_reg} = machine
    if Enum.count(program) >= 12 do
      case Enum.take(Enum.drop(Enum.sort(program), 3), 9) do
	[{3, {{:mulr, _}, [r1, r2, r4]}},
	 {4, {{:eqrr, _}, [r4, r3, r4]}},
	 {5, {{:addr, _}, [r4, ^ip_reg, ^ip_reg]}},
	 {6, {{:addi, _}, [^ip_reg, 1, ^ip_reg]}},
	 {7, {{:addr, _}, [r1, r0, r0]}},
	 {8, {{:addi, _}, [r2, r1, r2]}},
	 {9, {{:gtrr, _}, [r2, r3, r4]}},
	 {10, {{:addr, _}, [^ip_reg, r4, ^ip_reg]}},
         {11, {{:seti, _}, [r2, _, ^ip_reg]}}] ->
	  # Install a breakpoint that executes especially optimized code
	  # for the inner loop.
	  Machine.set_breakpoint(machine, 3, &(breakpoint1(&1, [r0, r1, r2, r3, r4, ip_reg])))
	_other ->
	  # The optimization doesn't apply.
	  machine
      end
    else
      machine
    end
  end

  defp breakpoint1 machine, reg_order do
    %{regs: regs} = machine
    [r0, r1, r2, r3 | _] = Enum.map(reg_order, &(elem(regs, &1)))
    result = loop r0, r1, r2, r3
    regs = List.to_tuple(Enum.map(reg_order, &(Map.fetch!(result, &1))))
    ip = 12
    %{machine | regs: regs, ip: ip}
  end

  defp loop r0, r1, r2, r3 do
    # 3: mulr 1, 2, 4
    r4 = r1 * r2

    # 4:  eqrr 4, 3, 4
    # 5:  jmpr 4
    # 6:  goto 8
    r0 = if r4 == r3 do
      # 7:  addr 1, 0, 0
      r0 + r1
    else
      r0
    end

    # 8:  addi 2, 1, 2
    r2 = r2 + 1

    # Optimize by incrementing r2 as much as possible without triggering
    # either r2 > r2 or r4 == r3.

    r2 = if r3 > r2 and r2 * r1 > r3 do
      r3
    else
      r2
    end

    # 9:  gtrr 2, 3, 4
    if r2 > r3 do
      Map.new([{0, r0}, {1, r1}, {2, r2}, {3, r3}, {4, 1}, {5, nil}])
    else
      loop r0, r1, r2, r3
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
      program: program, breakpoints: %{}, trace: trace}
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
	      :io.format('~2w: ~-30w ~-15s ~p\n',
		[ip, regs0, pp_instr(instr, ip_reg, ip, false), regs])
	    end
	    ip = elem(regs, ip_reg)
	    ip = ip + 1
	    machine = %{machine | ip: ip, regs: regs}
	    execute_program machine
	end
      %{} ->
	machine.regs
    end
  end

  def print_program machine do
    %{program: program, ip_reg: ip_reg} = machine
    IO.puts ""
    program
    |> Enum.sort
    |> Enum.each(fn {ip,instr} ->
      :io.format("~2w:  ~s\n", [ip, pp_instr(instr, ip_reg, ip, true)])
    end)
  end

  def pp_instr {{name, _}, operands}, ip_reg, ip, comment do
    case translate(name, operands, ip_reg, ip) do
      {^name, _} ->
	[Atom.to_charlist(name), " ",
	 Enum.intersperse(Enum.map(operands, &Integer.to_charlist/1), ", ")]
      {other_name, other_operands} ->
	[Atom.to_charlist(other_name), " ",
	 Enum.intersperse(Enum.map(other_operands, &Integer.to_charlist/1), ", ") |
	 case comment do
	   true ->
	     ["             # ",
	      Atom.to_charlist(name), " ",
	      Enum.intersperse(Enum.map(operands, &Integer.to_charlist/1), ", ")]
	   false ->
	     []
	 end]
    end
  end

  defp translate(:seti, [new_ip, _, ip_reg], ip_reg, _), do: {:goto, [new_ip+1]}
  defp translate(:addi, [ip_reg, offset, ip_reg], ip_reg, ip), do: {:goto, [ip+offset+1]}
  defp translate(:addr, [offset, ip_reg, ip_reg], ip_reg, _), do: {:jmpr, [offset]}
  defp translate(:addr, [ip_reg, offset, ip_reg], ip_reg, _), do: {:jmpr, [offset]}
  defp translate(name, operands, _ip_reg, _), do: {name, operands}

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
