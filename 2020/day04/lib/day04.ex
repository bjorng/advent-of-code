defmodule Day04 do
  def part1(input) do
    mandatory = mandatory_fields()
    parse(input)
    |> Enum.count(fn passport ->
      fields = Enum.map(passport, &elem(&1, 0))
      |> MapSet.new()
      MapSet.subset?(mandatory, fields)
    end)
  end

  def part2(input) do
    validations = validations()
    parse(input)
    |> Enum.count(fn passport ->
      Enum.all?(validations, fn {name, validate} ->
        case List.keyfind(passport, name, 0) do
          {^name, value} ->
            validate.(value)
          nil ->
            false
        end
      end)
    end)
  end

  defp validations do
    [{"byr", &byr/1},
     {"iyr", &iyr/1},
     {"eyr", &eyr/1},
     {"hgt", &hgt/1},
     {"hcl", &hcl/1},
     {"ecl", &ecl/1},
     {"pid", &pid/1}]
  end

  defp byr(val) do
    validate(val, ~r/^\d{4}$/, 1920..2002)
  end

  defp iyr(val) do
    validate(val, ~r/^\d{4}$/, 2010..2020)
  end

  defp eyr(val) do
    validate(val, ~r/^\d{4}$/, 2020..2030)
  end

  defp hgt(val) do
    case Regex.scan(~r/(^\d+)cm$/, val, capture: :all_but_first) do
      [[len]] ->
        String.to_integer(len) in 150..193
      [] ->
        case Regex.scan(~r/(^\d+)in$/, val, capture: :all_but_first) do
          [[len]] ->
            String.to_integer(len) in 59..76
          [] ->
            false
        end
    end
  end

  defp hcl(val) do
    validate(val, ~r/^#[0-9a-f]{6}$/)
  end

  defp ecl(val) do
    case val do
      "amb" -> true
      "blu" -> true
      "brn" -> true
      "gry" -> true
      "grn" -> true
      "hzl" -> true
      "oth" -> true
      _ -> false
    end
  end

  defp pid(val) do
    validate(val, ~r/^\d{9}$/)
  end

  defp validate(val, re, range \\ nil) do
    val =~ re && (range == nil || String.to_integer(val) in range)
  end

  defp mandatory_fields do
    ~w(byr iyr eyr hgt hcl ecl pid)
    |> MapSet.new
  end

  defp parse(input) do
    input
    |> Enum.chunk_by(fn line -> line == "" end)
    |> Enum.flat_map(fn
      [""] -> []
      chunk -> [Enum.join(chunk, " ")]
    end)
    |> Enum.map(fn string ->
      String.split(string, " ")
      |> Enum.map(fn field ->
        String.split(field, ":")
        |> List.to_tuple
      end)
    end)
  end
end
