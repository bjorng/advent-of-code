defmodule Day16 do
  def part1(input) do
    bin = parse(input)
    {packet, _} = decode_packet(bin)
    version_sum(packet, 0)
  end

  def part2(input) do
    bin = parse(input)
    {packet, _} = decode_packet(bin)
    eval_packet(packet)
  end

  defp version_sum({version, :literal, _}, sum) do
    sum + version
  end
  defp version_sum({version, _, packets}, sum) do
    Enum.reduce(packets, sum + version, &version_sum/2)
  end

  defp eval_packet({_, :literal, value}), do: value
  defp eval_packet({_, id, arguments}) do
    arguments = Enum.map(arguments, &eval_packet/1)
    case id do
      0 ->
        Enum.sum(arguments)
      1 ->
        Enum.reduce(arguments, 1, &*/2)
      2 ->
        Enum.min(arguments)
      3 ->
        Enum.max(arguments)
      5 ->
        [first, second] = arguments
        if first > second, do: 1, else: 0
      6 ->
        [first, second] = arguments
        if first < second, do: 1, else: 0
      7 ->
        [first, second] = arguments
        if first == second, do: 1, else: 0
    end
  end

  defp decode_packet(bin) do
    case bin do
      <<version::size(3), id::size(3), rest::bitstring>> ->
        case id do
          4 ->
            {literal, rest} = decode_literal_package(rest)
            {{version, :literal, literal}, rest}
          _ ->
            {packets, rest} = decode_operator_packet(rest)
            {{version, id, packets}, rest}
        end
      _ ->
        {:none, bin}
    end
  end

  defp decode_literal_package(bitstring, acc \\ 0) do
    case bitstring do
      <<more::size(1), n::size(4), rest::bitstring>> ->
        acc = acc * 16 + n
        case more do
          0 -> {acc, rest}
          1 -> decode_literal_package(rest, acc)
        end
    end
  end

  defp decode_operator_packet(bitstring) do
    case bitstring do
      <<0::size(1), total_size::size(15), rest::bitstring>> ->
        <<packets::bitstring-size(total_size), rest::bitstring>> = rest
        {packets, <<>>} = decode_packets(packets, [])
        {packets, rest}
      <<1::size(1), num_packets::size(11), rest::bitstring>> ->
        decode_n_packets(rest, num_packets, [])
    end
  end

  defp decode_packets(bitstring, acc) do
    case decode_packet(bitstring) do
      {:none, rest} ->
        {Enum.reverse(acc), rest}
      {packet, rest} ->
        decode_packets(rest, [packet | acc])
    end
  end

  defp decode_n_packets(bitstring, 0, acc) do
    {Enum.reverse(acc), bitstring}
  end
  defp decode_n_packets(bitstring, num_packets, acc) do
    {packet, rest} = decode_packet(bitstring)
    decode_n_packets(rest, num_packets - 1, [packet | acc])
  end

  defp parse(input) do
    int = String.to_integer(input, 16)
    nibbles = byte_size(input)
    <<int::integer-size(nibbles)-unit(4)>>
  end
end
