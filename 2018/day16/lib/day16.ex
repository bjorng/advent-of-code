defmodule Day16 do
  def part1(input) do
    {lines, _} = parse(input)
    samples = parse_samples lines
    Enum.reduce(samples, 0, fn sample, acc ->
      if num_matching(sample) >= 3 do
	acc + 1
      else
	acc
      end
    end)
  end

  def part2(input) do
    {samples, program} = parse(input)
    samples = parse_samples samples
    program = parse_program program
    instr_set = Machine.instructions()
    opcodes = Enum.zip(0..15, List.duplicate(instr_set, 16))
    |> Map.new

    opcodes = Enum.reduce(samples, opcodes, fn sample, acc ->
      {bef, [opcode | args], aft} = sample
      instrs = acc[opcode]
      |> Enum.filter(fn instr ->
	Machine.execute(instr, args, bef) == aft
      end)
      %{acc | opcode => instrs}
    end)
    |> resolve([])

    regs = {0, 0, 0, 0}
    Enum.reduce(program, regs, fn instr_application, acc ->
      [opcode | args] = instr_application;
      {_name, instr} = opcodes[opcode]
      instr.(args, acc)
    end)
    |> IO.inspect
    |> elem(0)
  end

  defp resolve opcodes, acc do
    groups = Enum.group_by(opcodes, fn {_opcode, instructions} ->
      length(instructions) == 1
    end)
    resolved = groups[true]
    resolved = Enum.map(resolved, fn {opcode, [instr]} ->
      {opcode, instr}
    end)
    acc = resolved ++ acc
    case groups[false] do
      nil ->
	Map.new acc
      unresolved ->
	resolved_names =
	  Enum.map(resolved, fn {_, {name, _}}  ->
	    name
	  end)
	unresolved = Enum.map(unresolved, fn {opcode, instrs} ->
	  instrs = Enum.reject(instrs, fn {name, _} ->
	  name in resolved_names end);
	  {opcode, instrs}
	end)
	resolve unresolved, acc
    end
  end

  defp num_matching {bef, [_opcode | args], aft} do
    Enum.reduce(Machine.instructions, 0, fn instr, acc ->
      case Machine.execute(instr, args, bef) do
	nil ->
	  acc
	^aft ->
	  acc + 1
	_ ->
	  acc
      end
    end)
  end

  defp parse_samples [<<"Before: ", bef::binary>>,
		      instr,
		      <<"After:  ", aft::binary>> | lines] do
    bef = parse_reg_list bef
    instr = parse_integers instr
    aft = parse_reg_list aft
    [{List.to_tuple(bef), instr, List.to_tuple(aft)} | parse_samples(lines)]
  end

  defp parse_samples [] do
    []
  end

  defp parse_reg_list <<"[", string::binary>> do
    String.split(string, ", ", trim: true)
    |> Enum.map(fn s ->
      {int, _} = Integer.parse(s)
      int
    end)
  end

  defp parse_integers string do
    String.split(string, " ")
    |> Enum.map(fn s ->
      {int, ""} = Integer.parse(s)
      int
    end)
  end

  defp parse_program lines do
    Enum.map(lines, &parse_integers/1)
  end

  defp parse(input) do
    [samples, program] = String.split(input, "\n\n\n")
    {String.split(samples, "\n", trim: true),
     String.split(program, "\n", trim: true)}
  end
end

defmodule Machine do
  use Bitwise

  def instruction_name({name, instruction}) when is_function(instruction, 2) do
    name
  end

def execute {_name, instr}, args, regs do
    try do
      instr.(args, regs)
    rescue
      RuntimeError ->
	nil
    end
  end

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

      iex> Machine.addr [1, 2, 0], {1, 4, 5, 10}
      {9, 4, 5, 10}

  """

  def addr [a, b, c], regs do
    put_elem regs, c, elem(regs, a) + elem(regs, b)
  end

  @doc """
  addi (add immediate) stores into register C the result of adding
  register A and value B.


  ## Examples

      iex> Machine.addi [1, 42, 3], {1, 4, 5, 10}
      {1, 4, 5, 46}

  """

  def addi [a, b, c], regs do
    put_elem regs, c, elem(regs, a) + b
  end

  @doc """
  mulr (multiply register) stores into register C the result of
  multiplying register A and register B.

  ## Examples

      iex> Machine.mulr [1, 2, 0], {1, 4, 5, 10}
      {20, 4, 5, 10}

  """

  def mulr [a, b, c], regs do
    put_elem regs, c, elem(regs, a) * elem(regs, b)
  end

  @doc """
  muli (multiply immediate) stores into register C the result of multiplying
  register A and value B.


  ## Examples

      iex> Machine.muli [1, 42, 3], {1, 4, 5, 10}
      {1, 4, 5, 168}

  """

  def muli [a, b, c], regs do
    put_elem regs, c, elem(regs, a) * b
  end

  @doc """
  banr (bitwise AND register) stores into register C the result of the
  bitwise AND of register A and register B.

  ## Examples

      iex> Machine.banr [1, 2, 0], {1, 5, 13, 10}
      {5, 5, 13, 10}

  """

  def banr [a, b, c], regs do
    put_elem regs, c, band(elem(regs, a), elem(regs, b))
  end

  @doc """
  bani (bitwise AND immediate) stores into register C the result of
  the bitwise AND of register A and value B.

  ## Examples

      iex> Machine.bani [3, 8, 0], {1, 4, 5, 10}
      {8, 4, 5, 10}

  """

  def bani [a, b, c], regs do
    put_elem regs, c, band(elem(regs, a), b)
  end

  @doc """
  borr (bitwise OR register) stores into register C the result of
  the bitwise OR of register A and register B.

  ## Examples

      iex> Machine.borr [1, 2, 0], {1, 5, 9, 10}
      {13, 5, 9, 10}

  """

  def borr [a, b, c], regs do
    put_elem regs, c, bor(elem(regs, a), elem(regs, b))
  end

  @doc """
  bori (bitwise OR immediate) stores into register C the result of
  the bitwise OR of register A and value B.

  ## Examples

      iex> Machine.bori [3, 32, 0], {1, 4, 5, 10}
      {42, 4, 5, 10}

  """

  def bori [a, b, c], regs do
    put_elem regs, c, bor(elem(regs, a), b)
  end

  @doc """
  setr (set register) copies the contents of register A into register C.
  (Input B is ignored.)

  ## Examples

      iex> Machine.setr [3, 999, 1], {1, 4, 5, 10}
      {1, 10, 5, 10}

  """

  def setr [a, _b, c], regs do
    put_elem regs, c, elem(regs, a)
  end

  @doc """
  seti (set immediate) stores value A into register C. (Input B is ignored.)

  ## Examples

      iex> Machine.seti [777, 999, 0], {1, 4, 5, 10}
      {777, 4, 5, 10}

  """

  def seti [a, _b, c], regs do
    put_elem regs, c, a
  end

  @doc """
  gtir (greater-than immediate/register) sets register C to 1 if value A
  is greater than register B. Otherwise, register C is set to 0.


  ## Examples

      iex> Machine.gtir [7, 2, 0], {1, 4, 5, 10}
      {1, 4, 5, 10}
      iex> Machine.gtir [0, 2, 0], {1, 4, 5, 10}
      {0, 4, 5, 10}

  """

  def gtir [a, b, c], regs do
    put_bool regs, c, a > elem(regs, b)
  end

  @doc """
  gtri (greater-than register/immediate) sets register C to 1 if register A
  is greater than value B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.gtri [3, 9, 0], {1, 4, 5, 10}
      {1, 4, 5, 10}
      iex> Machine.gtri [2, 9, 0], {1, 4, 5, 10}
      {0, 4, 5, 10}

  """

  def gtri [a, b, c], regs do
    put_bool regs, c, elem(regs, a) > b
  end

  @doc """
  gtrr (greater-than register/register) sets register C to 1 if register A
  is greater than register B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.gtrr [3, 2, 0], {1, 4, 5, 10}
      {1, 4, 5, 10}
      iex> Machine.gtrr [1, 2, 0], {1, 4, 5, 10}
      {0, 4, 5, 10}

  """

  def gtrr [a, b, c], regs do
    put_bool regs, c, elem(regs, a) > elem(regs, b)
  end

  @doc """
  eqir (equal immediate/register) sets register C to 1 if value A is
  equal to register B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.eqir [4, 1, 0], {1, 4, 5, 10}
      {1, 4, 5, 10}
      iex> Machine.eqir [42, 1, 0], {1, 4, 5, 10}
      {0, 4, 5, 10}

  """

  def eqir [a, b, c], regs do
    put_bool regs, c, a == elem(regs, b)
  end

  @doc """
  eqri (equal register/immediate) sets register C to 1 if register A
  is equal to value B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.eqri [3, 10, 0], {1, 4, 5, 10}
      {1, 4, 5, 10}
      iex> Machine.eqri [3, 19, 0], {1, 4, 5, 10}
      {0, 4, 5, 10}

  """

  def eqri [a, b, c], regs do
    put_bool regs, c, elem(regs, a) == b
  end

  @doc """
  eqrr (equal register/register) sets register C to 1 if register A
  is equal to register B. Otherwise, register C is set to 0.

  ## Examples

      iex> Machine.eqrr [3, 2, 0], {1, 4, 5, 10}
      {0, 4, 5, 10}
      iex> Machine.eqrr [3, 2, 0], {1, 4, 10, 10}
      {1, 4, 10, 10}

  """

  def eqrr [a, b, c], regs do
    put_bool regs, c, elem(regs, a) == elem(regs, b)
  end

  defp put_bool regs, c, bool do
    bool = if bool, do: 1, else: 0
    put_elem regs, c, bool
  end

end
