defmodule Day07Test do
  use ExUnit.Case
  #doctest Day07

  test "part one example" do
    assert Day07.top_sort_lines(data()) == 'CABDFE'
  end

  test "part one real data" do
    assert Day07.top_sort_lines(input()) == 'CFGHAEMNBPRDISVWQUZJYTKLOX'
  end

  test "part two example" do
    assert Day07.execute_lines(data(), 2, 0) == 15
  end

  test "part two real data" do
    assert Day07.execute_lines(input(), 5, 60) == 828
  end

  defp data() do
  """
  Step C must be finished before step A can begin.
  Step C must be finished before step F can begin.
  Step A must be finished before step B can begin.
  Step A must be finished before step D can begin.
  Step B must be finished before step E can begin.
  Step D must be finished before step E can begin.
  Step F must be finished before step E can begin.
  """
  |> String.trim
  |> String.split("\n")
  end

  defp input do
    """
    Step G must be finished before step N can begin.
    Step N must be finished before step B can begin.
    Step P must be finished before step Q can begin.
    Step F must be finished before step U can begin.
    Step H must be finished before step A can begin.
    Step C must be finished before step S can begin.
    Step A must be finished before step K can begin.
    Step M must be finished before step O can begin.
    Step V must be finished before step L can begin.
    Step E must be finished before step L can begin.
    Step B must be finished before step Q can begin.
    Step W must be finished before step J can begin.
    Step R must be finished before step D can begin.
    Step D must be finished before step S can begin.
    Step S must be finished before step X can begin.
    Step Q must be finished before step J can begin.
    Step I must be finished before step L can begin.
    Step U must be finished before step J can begin.
    Step Z must be finished before step X can begin.
    Step Y must be finished before step T can begin.
    Step J must be finished before step K can begin.
    Step T must be finished before step L can begin.
    Step K must be finished before step O can begin.
    Step O must be finished before step X can begin.
    Step L must be finished before step X can begin.
    Step Y must be finished before step O can begin.
    Step F must be finished before step S can begin.
    Step K must be finished before step L can begin.
    Step Z must be finished before step O can begin.
    Step J must be finished before step X can begin.
    Step K must be finished before step X can begin.
    Step Q must be finished before step X can begin.
    Step Y must be finished before step L can begin.
    Step E must be finished before step S can begin.
    Step H must be finished before step Y can begin.
    Step G must be finished before step P can begin.
    Step E must be finished before step K can begin.
    Step B must be finished before step L can begin.
    Step T must be finished before step K can begin.
    Step N must be finished before step R can begin.
    Step F must be finished before step E can begin.
    Step W must be finished before step Y can begin.
    Step U must be finished before step X can begin.
    Step A must be finished before step I can begin.
    Step Q must be finished before step Y can begin.
    Step P must be finished before step T can begin.
    Step D must be finished before step X can begin.
    Step E must be finished before step Y can begin.
    Step F must be finished before step B can begin.
    Step P must be finished before step I can begin.
    Step N must be finished before step S can begin.
    Step F must be finished before step V can begin.
    Step W must be finished before step U can begin.
    Step F must be finished before step A can begin.
    Step I must be finished before step Z can begin.
    Step E must be finished before step D can begin.
    Step R must be finished before step I can begin.
    Step M must be finished before step V can begin.
    Step R must be finished before step U can begin.
    Step R must be finished before step X can begin.
    Step G must be finished before step O can begin.
    Step G must be finished before step H can begin.
    Step M must be finished before step R can begin.
    Step E must be finished before step U can begin.
    Step F must be finished before step Z can begin.
    Step N must be finished before step Q can begin.
    Step U must be finished before step O can begin.
    Step J must be finished before step T can begin.
    Step W must be finished before step Z can begin.
    Step I must be finished before step J can begin.
    Step U must be finished before step L can begin.
    Step I must be finished before step X can begin.
    Step Z must be finished before step J can begin.
    Step F must be finished before step D can begin.
    Step N must be finished before step O can begin.
    Step Q must be finished before step U can begin.
    Step G must be finished before step L can begin.
    Step H must be finished before step Q can begin.
    Step M must be finished before step Q can begin.
    Step N must be finished before step D can begin.
    Step Z must be finished before step L can begin.
    Step I must be finished before step Y can begin.
    Step E must be finished before step X can begin.
    Step J must be finished before step L can begin.
    Step H must be finished before step W can begin.
    Step P must be finished before step Y can begin.
    Step Q must be finished before step T can begin.
    Step Z must be finished before step Y can begin.
    Step R must be finished before step T can begin.
    Step E must be finished before step J can begin.
    Step I must be finished before step T can begin.
    Step A must be finished before step L can begin.
    Step E must be finished before step R can begin.
    Step T must be finished before step O can begin.
    Step Y must be finished before step X can begin.
    Step A must be finished before step Q can begin.
    Step W must be finished before step Q can begin.
    Step A must be finished before step T can begin.
    Step B must be finished before step Y can begin.
    Step H must be finished before step E can begin.
    Step H must be finished before step K can begin.
    """
    |> String.trim
    |> String.split("\n")
  end
end
