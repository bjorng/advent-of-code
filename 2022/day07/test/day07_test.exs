defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "part 1 with example" do
    assert Day07.part1(example()) == 95437
  end

  # 1038055 is too low.
  test "part 1 with my input data" do
    assert Day07.part1(input()) == 1391690
  end

  test "part 2 with example" do
    assert Day07.part2(example()) == 24933642
  end

  test "part 2 with my input data" do
    assert Day07.part2(input()) == 5469168
  end

  defp example() do
    """
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """
    |> String.split("\n", trim: true)
  end

  defp input() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
  end
end
