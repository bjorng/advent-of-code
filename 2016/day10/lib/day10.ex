defmodule Day10 do
  def part1(input, chip_list \\ [17, 61]) do
    solve(input, chip_list)
    |> Map.fetch!(:result)
    |> elem(1)
  end

  def part2(input) do
    solve(input, nil)
    |> result_part2
  end

  defp solve(input, chip_list) do
    instructions = Parser.parse(input)

    state = init_state(instructions)
    |> Map.put(:chip_list, chip_list)

    fully_chipped = Map.to_list(state)
    |> Enum.filter(fn pair ->
      case pair do
        {{:bot, _}, [_low, _high]} -> true
        _ -> false
      end
    end)
    |> Enum.map(&elem(&1, 0))

    distribute_chips(state, fully_chipped)
  end

  defp result_part2(state) do
    %{{:output, 0} => [output0],
      {:output, 1} => [output1],
      {:output, 2} => [output2]} = state
    output0 * output1 * output2
  end

  defp init_state(instructions) do
    Enum.reduce(instructions, %{}, fn instruction, state ->
      case instruction do
        {:value, bot, value} ->
          chips = Map.get(state, bot, [])
          chips = Enum.sort([value | chips])
          Map.put(state, bot, chips)
        {:give, from, low_dest, high_dest} ->
          Map.put(state, {:give, from}, {low_dest, high_dest})
      end
    end)
  end

  defp distribute_chips(state, []), do: state
  defp distribute_chips(state, [{:bot, _} = bot | bots]) do
    state = give_chips(state, bot)
    distribute_chips(state, bots)
  end
  defp distribute_chips(state, [{:output, _} | bots]) do
    distribute_chips(state, bots)
  end

  defp give_chips(state, from) do
    {low_dest, high_dest} = Map.get(state, {:give, from})
    low_high = Map.fetch!(state, from)
    case low_high do
      [low, high] ->
        chip_list = Map.fetch!(state, :chip_list)
        state = if (low_high === chip_list) do
          Map.put(state, :result, from)
        else
          state
        end
        Map.put(state, from, [])
        |> give_to(low_dest, low)
        |> give_to(high_dest, high)
        |> distribute_chips([low_dest, high_dest])
      _ ->
        state
    end
  end

  defp give_to(state, destination, value) do
    chips = Map.get(state, destination, [])
    chips = Enum.sort([value | chips])
    Map.put(state, destination, chips)
  end
end

defmodule Parser do
  import NimbleParsec

  defp pack_value([value,bot]) do
    {:value, bot, value}
  end

  defp pack_give([from, bot_high, bot_low]) do
    {:give, from, bot_high, bot_low}
  end

  bot = ignore(string("bot "))
  |> integer(min: 1)
  |> unwrap_and_tag(:bot)

  output = ignore(string("output "))
  |> integer(min: 1)
  |> unwrap_and_tag(:output)

  destination = choice([bot, output])

  give = bot
  |> ignore(string(" gives low to "))
  |> concat(destination)
  |> ignore(string(" and high to "))
  |> concat(destination)
  |> reduce({:pack_give, []})

  value = ignore(string("value "))
  |> integer(min: 1)
  |> ignore(string(" goes to "))
  |> concat(bot)
  |> reduce({:pack_value, []})

  defparsec :command, choice([value, give]) |> eos

  def parse(input) do
    Enum.map(input, fn line ->
      {:ok, [result], "", _, _, _} = command(line)
      result
    end)
  end
end
