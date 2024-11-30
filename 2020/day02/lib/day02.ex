defmodule Day02 do
  def part1(input) do
    PasswordParser.parse(input)
    |> Enum.count(fn {{min,max}, letter, password} ->
      [letter] = String.to_charlist(letter)
      n = String.to_charlist(password)
      |> Enum.count(&(&1 === letter))
      n in min..max
    end)
  end

  def part2(input) do
    PasswordParser.parse(input)
    |> Enum.count(fn {{pos1,pos2}, letter, password} ->
      chars = [String.at(password, pos1 - 1),
               String.at(password, pos2 - 1)]
      Enum.count(chars, fn char -> char === letter end) === 1
    end)
  end
end

defmodule PasswordParser do
  import NimbleParsec

  defp pack([min, max, letter, password]) do
    {{min,max}, letter, password}
  end

  entry = integer(min: 1)
  |> ignore(string("-"))
  |> integer(min: 1)
  |> ignore(string(" "))
  |> ascii_string([?a..?z], 1)
  |> ignore(string(": "))
  |> ascii_string([?a..?z], min: 1)
  |> eos()
  |> reduce({:pack, []})

  defparsecp :entry, entry

  def parse(input) do
    Enum.map(input, fn(line) ->
      {:ok, [res], _, _, _, _} = entry(line)
      res
    end)
  end
end
