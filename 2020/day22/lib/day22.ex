defmodule Day22 do
  def part1(input) do
    parse(input)
    |> Enum.map(&init_hand/1)
    |> Stream.iterate(&play/1)
    |> Stream.drop_while(&no_winner?/1)
    |> Enum.take(1)
    |> hd
    |> Enum.map(&hand_to_list/1)
    |> Enum.reject(&(match?([], &1)))
    |> hd
    |> score
  end

  def part2(input) do
    parse(input)
    |> Enum.map(&init_hand/1)
    |> recursive_combat
    |> score_part2
  end


  #
  # Part 1
  #

  defp no_winner?(players) do
    Enum.all?(players, fn hand -> not hand_is_empty?(hand) end)
  end

  defp play(players) do
    [{card1, hand1}, {card2, hand2}] = Enum.map(players, &take_card/1)
    if card1 > card2 do
      [put_back(hand1, card1, card2), hand2]
    else
      [hand1, put_back(hand2, card2, card1)]
    end
  end

  defp score(hand) do
    Enum.reverse(hand)
    |> Stream.with_index(1)
    |> Enum.reduce(0, fn {card, value}, sum ->
      sum + card * value
    end)
  end


  #
  # Part 2.
  #

  defp recursive_combat(players) do
    recursive_combat(players, init_history())
  end

  defp recursive_combat(players, history) do
    case state_seen?(history, players) do
      true ->
        # Player one wins.
        {1, hd(players)}
      false ->
        history = update_history(history, players)
        recursive_combat_play(players, history)
    end
  end

  defp recursive_combat_play(players, history) do
    [{card1, hand1}, {card2, hand2}] = Enum.map(players, &take_card/1)
    players = case play_one(card1, hand1, card2, hand2) do
                1 ->
                  [put_back(hand1, card1, card2), hand2]
                2 ->
                  [hand1, put_back(hand2, card2, card1)]
              end
    case no_winner?(players) do
      true ->
        recursive_combat(players, history)
      false ->
        [hand1, hand2] = players
        case hand_is_empty?(hand2) do
          true -> {1, hand1}
          false -> {2, hand2}
        end
    end
  end

  defp play_one(card1, hand1, card2, hand2) do
    case num_cards_on_hand(hand1) >= card1 and num_cards_on_hand(hand2) >= card2 do
      true ->
        # Start new recursive game.
        new_game = [take_cards(hand1, card1), take_cards(hand2, card2)]
        |> Enum.map(&init_hand/1)
        {winner, _} = recursive_combat(new_game)
        winner
      false ->
        if card1 > card2 do
          1
        else
          2
        end
    end
  end

  defp score_part2({_, hand}) do
    score(hand_to_list(hand))
  end

  #
  # Abstraction for the cards on hand.
  #
  # I first tried to use the `queue` module, but it turned out
  # be slower than using a simple list in part 2 because of
  # the need to test for a previous state.  (A `queue` could
  # not simply be put into a MapSet, but would have to be
  # normalized by calling `:queue.to_list/1`.)
  #

  defp init_hand(hand) do
    hand
  end

  defp hand_is_empty?(hand) do
    hand === []
  end

  defp hand_to_list(hand) do
    hand
  end

  defp num_cards_on_hand(hand) do
    length(hand)
  end

  defp take_card([card | hand]), do: {card, hand}

  defp take_cards(hand, n) do
    Enum.take(hand, n)
  end

  defp put_back(hand, card1, card2) do
    hand ++ [card1, card2]
  end

  #
  # Keep track of previous states.
  #

  defp init_history() do
    MapSet.new()
  end

  defp update_history(history, players) do
    players = Enum.map(players, &hand_to_list/1)
    MapSet.put(history, players)
  end

  defp state_seen?(history, players) do
    players = Enum.map(players, &hand_to_list/1)
    MapSet.member?(history, players)
  end

  #
  # Parse input.
  #

  defp parse(input) do
    {[_|list1], [_|list2]} = Enum.split(input, div(length(input), 2))
    [Enum.map(list1, &String.to_integer/1),
     Enum.map(list2, &String.to_integer/1)]
  end
end
