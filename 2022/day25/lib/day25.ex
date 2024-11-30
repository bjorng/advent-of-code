defmodule Day25 do
  def part1(input) do
    parse(input)
    |> Enum.sum
    |> decimal_to_snafu
  end

  @doc """
  Converts a SNAFU number to a decimal number.

  ## Examples

      iex> Day25.snafu_to_decimal("1")
      1

      iex> Day25.snafu_to_decimal("2")
      2

      iex> Day25.snafu_to_decimal("1=")
      3

      iex> Day25.snafu_to_decimal("1-")
      4

      iex> Day25.snafu_to_decimal("10")
      5

      iex> Day25.snafu_to_decimal("11")
      6

      iex> Day25.snafu_to_decimal("12")
      7

      iex> Day25.snafu_to_decimal("2=")
      8

      iex> Day25.snafu_to_decimal("2-")
      9

      iex> Day25.snafu_to_decimal("20")
      10

      iex> Day25.snafu_to_decimal("1=0")
      15

      iex> Day25.snafu_to_decimal("1-0")
      20

      iex> Day25.snafu_to_decimal("1=11-2")
      2022

      iex> Day25.snafu_to_decimal("1-0---0")
      12345

      iex> Day25.snafu_to_decimal("1121-1110-1=0")
      314159265

      iex> Day25.snafu_to_decimal("1=-0-2")
      1747

      iex> Day25.snafu_to_decimal("12111")
      906
  """
  def snafu_to_decimal(snafu_number) do
    Enum.reduce(String.to_charlist(snafu_number), 0, fn digit, acc ->
      acc * 5 +
      case digit do
        ?= -> -2
        ?- -> -1
        _ -> digit - ?0
      end
    end)
  end

  @doc """
  Converts a SNAFU number to a decimal number.

  ## Examples

      iex> Day25.decimal_to_snafu(1)
      "1"

      iex> Day25.decimal_to_snafu(2)
      "2"

      iex> Day25.decimal_to_snafu(3)
      "1="

      iex> Day25.decimal_to_snafu(4)
      "1-"

      iex> Day25.decimal_to_snafu(5)
      "10"

      iex> Day25.decimal_to_snafu(6)
      "11"

      iex> Day25.decimal_to_snafu(7)
      "12"

      iex> Day25.decimal_to_snafu(8)
      "2="

      iex> Day25.decimal_to_snafu(9)
      "2-"

      iex> Day25.decimal_to_snafu(10)
      "20"

      iex> Day25.decimal_to_snafu(15)
      "1=0"

      iex> Day25.decimal_to_snafu(20)
      "1-0"

      iex> Day25.decimal_to_snafu(2022)
      "1=11-2"

      iex> Day25.decimal_to_snafu(12345)
      "1-0---0"

      iex> Day25.decimal_to_snafu(314159265)
      "1121-1110-1=0"

      iex> Day25.decimal_to_snafu(4890)
      "2=-1=0"


  """
  def decimal_to_snafu(decimal) do
    decimal_to_snafu(decimal, [])
  end

  defp decimal_to_snafu(0, acc), do: List.to_string(acc)
  defp decimal_to_snafu(decimal, acc) do
    case rem(decimal, 5) do
      0 -> decimal_to_snafu(div(decimal, 5), [?0|acc])
      1 -> decimal_to_snafu(div(decimal, 5), [?1|acc])
      2 -> decimal_to_snafu(div(decimal, 5), [?2|acc])
      3 -> decimal_to_snafu(div(decimal, 5) + 1, [?=|acc])
      4 -> decimal_to_snafu(div(decimal, 5) + 1, [?-|acc])
    end
  end

  defp parse(input) do
    input
    |> Enum.map(&snafu_to_decimal/1)
  end
end
