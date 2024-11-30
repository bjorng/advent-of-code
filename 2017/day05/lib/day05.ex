defmodule Day05 do
  def part1(stream) do
    program = get_program(stream)
    execute(0, program, 0, & &1 + 1)
  end

  def part2(stream) do
    program = get_program(stream)
    execute(0, program, 0, &(if &1 >= 3, do: &1 - 1, else: &1 + 1))
  end

  defp get_program(stream) do
    stream
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index
    |> Stream.map(fn {offset, ip} -> {ip, offset} end)
    |> Enum.to_list
    |> Map.new
  end

  defp execute(ip, program, steps, update) do
    case program do
      %{^ip => offset} ->
        program = %{program | ip => update.(offset)}
        ip = ip + offset
        execute(ip, program, steps + 1, update)
      %{} ->
        steps
    end
  end

end
