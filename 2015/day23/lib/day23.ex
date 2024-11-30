defmodule Day23 do
  def part1(input) do
    run(input, %{a: 0, b: 0})
  end

  def part2(input) do
    run(input, %{a: 1, b: 0})
  end

  defp run(input, regs) do
    prog = parse(input)
    |> Enum.with_index
    |> Enum.map(fn {instr, ip} -> {ip, instr} end)
    |> Map.new

    ip = 0
    execute(prog, ip, regs)
  end

  defp execute(prog, ip, regs) do
    case prog do
      %{^ip => instr} ->
        case instr do
          {:hlf, reg} ->
            regs = update_reg(regs, reg, &(div(&1, 2)))
            execute(prog, ip + 1, regs)
          {:tpl, reg} ->
            regs = update_reg(regs, reg, &(&1 * 3))
            execute(prog, ip + 1, regs)
          {:inc, reg} ->
            regs = update_reg(regs, reg, &(&1 + 1))
            execute(prog, ip + 1, regs)
          {:jmp, offset} ->
            execute(prog, ip + offset, regs)
          {:jie, reg, offset} ->
            if (rem(Map.fetch!(regs, reg), 2) === 0) do
              execute(prog, ip + offset, regs)
            else
              execute(prog, ip + 1, regs)
            end
          {:jio, reg, offset} ->
            if (Map.fetch!(regs, reg) === 1) do
              execute(prog, ip + offset, regs)
            else
              execute(prog, ip + 1, regs)
            end
        end
      %{} ->
        regs
    end
  end

  defp update_reg(regs, reg, f) do
    Map.update!(regs, reg, f)
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      [instr, reg | tail] = String.split(line)
      instr = String.to_atom(instr)
      case tail do
        [] ->
          case instr do
            :jmp ->
              {instr, String.to_integer(reg)}
            _ ->
              {instr, String.to_atom(reg)}
          end
        [offset] ->
          {instr, String.to_atom(String.trim(reg, ",")), String.to_integer(offset)}
      end
    end)
  end
end
