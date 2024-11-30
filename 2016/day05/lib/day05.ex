defmodule Day05 do
  def part1(input) do
    1..8
    |> Enum.map_reduce(0, fn _, acc ->
      find_password_char(input, acc)
    end)
    |> elem(0)
    |> Enum.join
    |> String.downcase
  end

  def part2(input) do
    find_password(input, 0, %{})
  end

  defp find_password_char(input, index) do
    case :erlang.md5([input | Integer.to_string(index)]) do
      <<0::size(20), char::size(4), _::binary>> ->
        {Integer.to_string(char, 16), index + 1}
      _ ->
        find_password_char(input, index + 1)
    end
  end

  defp find_password(input, index, password) do
    case :erlang.md5([input | Integer.to_string(index)]) do
      <<0::size(20), position::size(4), char::size(4), _::bitstring>> when position in 0..7 ->
        case Map.has_key?(password, position) do
          true ->
            find_password(input, index + 1, password)
          false ->
            char = Integer.to_string(char, 16)
            password = Map.put(password, position, char)
            case map_size(password) do
              8 ->
                password
                |> Map.to_list
                |> Enum.sort
                |> Enum.map(&elem(&1, 1))
                |> Enum.join
                |> String.downcase
              _ ->
                find_password(input, index + 1, password)
            end
        end
      _ ->
        find_password(input, index + 1, password)
    end
  end
end
