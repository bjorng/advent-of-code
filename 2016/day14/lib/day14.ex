defmodule Day14 do
  def part1(input) do
    hasher = &md5_as_hex/1
    solve(input, hasher)
  end

  def part2(input) do
    hasher = &stretched_hash/1
    solve(input, hasher)
  end

  defp solve(input, hasher) do
    cache = Map.new()
    Stream.iterate({-1, cache}, fn {index, cache} ->
      next_key_index(hasher, input, index + 1, cache)
    end)
    |> Stream.drop(64)
    |> Enum.take(1)
    |> hd
    |> elem(0)
  end

  defp next_key_index(hasher, salt, index, cache) do
    {hash, cache} = hash(hasher, salt, index, cache)
    case find_triplet(hash) do
      nil ->
        next_key_index(hasher, salt, index + 1, cache)
      digit ->
        case quintuple_in_next_1000?(digit, hasher, salt, index + 1, cache) do
          {false, cache} ->
            next_key_index(hasher, salt, index + 1, cache)
          {true, cache} ->
            {index, cache}
        end
    end
  end

  defp find_triplet(<<d::size(8), d::size(8), d::size(8), _::bitstring>>) do
    d
  end
  defp find_triplet(<<_::size(8), rest::bitstring>>) do
    find_triplet(rest)
  end
  defp find_triplet(<<>>), do: nil

  defp quintuple_in_next_1000?(digit, hasher, salt, index, cache) do
    digits = String.duplicate(<<digit>>, 5)
    quintuple_in_next?(1000, digits, hasher, salt, index, cache)
  end

  defp quintuple_in_next?(0, _, _, _, _, cache), do: {false, cache}
  defp quintuple_in_next?(left, digits, hasher, salt, index, cache) do
    {hash, cache} = hash(hasher, salt, index, cache)
    case String.contains?(hash, digits) do
      true ->
        {true, cache}
      false ->
        quintuple_in_next?(left - 1, digits, hasher, salt, index + 1, cache)
    end
  end

  @doc """
  ## Examples:
    iex> Day14.stretched_hash("abc0")
    "a107ff634856bb300138cac6568c0f24"
  """
  def stretched_hash(key) do
    Enum.reduce(0..2016, key, fn _, acc -> hashed_as_hex(acc) end)
    |> List.to_string
  end

  defp md5_as_hex(key) do
    hashed_as_hex(key)
    |> List.to_string
  end

  defp hashed_as_hex(key) do
    :erlang.md5(key)
    |> do_hashed_as_hex
  end

  defp do_hashed_as_hex(<<>>), do: []
  defp do_hashed_as_hex(<<byte1::size(8), byte2::size(8), rest::bitstring>>) do
    [byte_to_hex(byte1), byte_to_hex(byte2) | do_hashed_as_hex(rest)]
  end

  for i <- 0..255 do
    defp byte_to_hex(unquote(i)),
    do: unquote(Integer.to_string(i + 0x100, 16) |> String.slice(1, 2) |> String.downcase)
  end

  defp hash(hasher, salt, index, cache) do
    case cache do
      %{^index => hash} ->
        {hash, cache}
      %{} ->
        cache = replenish_cache(500, hasher, salt, index, cache)
        hash(hasher, salt, index, cache)
    end
  end

  defp replenish_cache(n, hasher, salt, index, cache) do
    index..index+n
    |> Task.async_stream(fn index ->
      {index, hasher.([salt | Integer.to_string(index)])}
    end, ordered: false)
    |> Enum.reduce(cache, fn {:ok, {index, hash}}, cache ->
      Map.put(cache, index, hash)
    end)
  end
end
