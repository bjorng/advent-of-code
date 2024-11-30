#
# To run tests:
#
#    elixir day02.exs
#
# To run part 1 and 2:
#
#    > iex day02.exs
#    [iex]> Day02.part1
#    [iex]> Day02.part2
#

defmodule Day02 do

  def part1() do
    checksum(string_stream("input.txt"))
  end

  def part2() do
    common(string_stream("input.txt"))
  end

  def checksum(list) do
    list = Enum.map list, fn e -> Enum.sort(String.to_charlist e) end
    twos = Enum.reduce list, 0, fn id, acc -> acc + count(id, 2) end
    threes = Enum.reduce list, 0, fn id, acc -> acc + count(id, 3) end
    twos * threes
  end

  def common ids do
    l = for i <- 0..byte_size(hd(ids))-1, do: Enum.group_by(ids, &(bin_key &1, i), &(bin_val &1, i))
    |> Enum.flat_map(fn {k, values} ->
      case values do
	[_,_] ->
	  [k];
	_ ->
	  []
      end
    end)
    hd(List.flatten l)
  end

  def bin_key bin, index do
    <<bef::binary-size(index), _::binary-size(1), aft::binary>> = bin
    bef <> aft
  end

  def bin_val bin, index do
    <<_::binary-size(index), val::binary-size(1), _::binary>> = bin
    val
  end

  def count([h|t], n) do
    case count(t, h, n-1) do
      {0,_} ->
	1
      {_,t} ->
	count(t, n)
    end
  end
  def count [], _ do
    0
  end

  def count [h|t], val, n do
    case h do
      ^val ->
	count t, val, n-1
      _ ->
	{n, [h|t]}
    end
  end
  def count [], _, n do
    {n, []}
  end

  def string_stream(f) do
    File.stream!(f)
    |> Enum.map(fn line -> String.trim(line) end)
  end
end

ExUnit.start()

defmodule Day02Test do
  use ExUnit.Case

  import Day02

  test "part one" do
    assert checksum(["abcdef","bababc","abbcde","abcccd","aabcdd","abcdee","ababab"]) == 12
  end

  test "part two" do
    assert common(["abcde","fghij","klmno","pqrst","fguij","axcye","wvxyz"]) == "fgij"
  end

end
