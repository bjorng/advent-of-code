defmodule Day17 do
  import Bitwise

  def part1(input) do
    {regs, program} = parse(input)
    regs = Map.new(regs)
    regs = Map.put(regs, :output, [])
    program = Map.new(Enum.zip(0..length(program), program))
    ip = 0
    regs = execute(program, ip, regs)
    Enum.reverse(regs.output)
    |> Enum.map(&(?0 + &1))
    |> Enum.intersperse(?,)
    |> List.to_string
  end

  def part2(input) do
    {regs, program0} = parse(input)
    regs0 = Map.new(regs)
    regs = Map.put(regs0, :output, nil)
    |> Map.put(:A, 0)
    program = Map.new(Enum.zip(0..length(program0), program0))
    result = solve_part2(program, regs, program0)
    ^program0 = verify_part2(input, result)
    result
  end

  defp verify_part2(input, a) do
    {regs, program} = parse(input)
    regs = Map.new(regs)
    regs = Map.put(regs, :output, [])
    |> Map.put(:A, a)
    program = Map.new(Enum.zip(0..length(program), program))
    ip = 0
    regs = execute(program, ip, regs)
    Enum.reverse(regs.output)
  end

  defp solve_part2(program, regs, expected) do
    # Looking at the program it can be seen that each output
    # value depends on the lower 10 bits of the value of the
    # A register.

    # Generate all possible A register values that produce the first
    # digit.
    initial = 0..1023
    |> Enum.map(fn a ->
      regs = Map.put(regs, :A, a)
      output = execute(program, 0, regs)
      {a, output}
    end)

    # Keep discarding the digits that don't match. For each of the
    # surviving elements, extend the A register value and generate the
    # next digit.
    expected
    |> Enum.reduce({initial, 10}, fn digit, {as, shift} ->
      Enum.flat_map(as, fn {a, d} ->
        if d === digit do
          Enum.flat_map(0..7, fn value ->
            a_acc = (value <<< shift) ||| a
            regs = Map.put(regs, :A, a_acc >>> (shift - 7))
            output = execute(program, 0, regs)
            [{a_acc, output}]
          end)
        else
          []
        end
      end)
      |> then(&{&1, shift+3})
    end)
    |> elem(0)
    |> Enum.min
    |> elem(0)
  end

  defp execute(program, ip, regs) do
    case program do
      %{^ip => opcode} ->
        case opcode do
          0 ->
            operand = combo(program, ip, regs)
            regs = Map.put(regs, :A, regs[:A] >>> operand)
            execute(program, ip + 2, regs)
          1 ->
            result = bxor(regs."B", program[ip + 1])
            regs = %{regs | B: result}
            execute(program, ip + 2, regs)
          2 ->
            operand = combo(program, ip, regs) &&& 7
            regs = %{regs | B: operand}
            execute(program, ip + 2, regs)
          3 ->
            ip = if regs[:A] === 0 do
                ip + 2
              else
                program[ip + 1]
              end
            execute(program, ip, regs)
          4 ->
            result = bxor(regs."B", regs."C")
            regs = %{regs | B: result}
            execute(program, ip + 2, regs)
          5 ->
            operand = combo(program, ip, regs) &&& 7
            case regs do
              %{output: nil} ->
                operand
              %{output: output} ->
                regs = %{regs | output: [operand | output]}
                execute(program, ip + 2, regs)
            end
          7 ->
            operand = combo(program, ip, regs)
            regs = Map.put(regs, :C, regs[:A] >>> operand)
            execute(program, ip + 2, regs)
        end
      %{} ->
        regs
    end
  end

  defp combo(program, ip, regs) do
    case Map.fetch!(program, ip + 1) do
      literal when literal in 0..3 ->
        literal
      reg when reg in 4..6 ->
        Map.fetch!(regs, List.to_existing_atom([?A + reg - 4]))
    end
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> then(fn [registers, program] ->
      rs = registers
      |> Enum.map(fn reg ->
        <<"Register ", reg, ": ", ns::binary>> = reg
        {List.to_atom([reg]), String.to_integer(ns)}
      end)
      "Program: " <> program = hd(program)
      program = String.split(program, ",")
      |> Enum.map(&String.to_integer/1)
      {rs, program}
    end)
  end
end
