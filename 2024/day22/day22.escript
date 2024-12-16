#!/usr/bin/env escript

main(_) ->
    Input = get_input(),
    io:format("Part 1: ~P\n", [part1(Input), 15]),
    io:format("Part 2: ~P\n", [part2(Input), 15]).

part1(Sellers) ->
    Seq = lists:seq(1, 2000),
    L = [lists:foldl(fun(_, S) ->
                             next_secret(S)
                     end, Secret, Seq) || Secret <- Sellers],
    lists:sum(L).

part2(Sellers) ->
    L = lists:flatmap(fun one_seller/1, Sellers),
    Groups = maps:groups_from_list(fun({Seq, _}) -> Seq end, L),
    Prices = [lists:sum([Price || {_,Price} <- G]) ||
                 _ := G <- Groups],
    lists:max(Prices).

one_seller(Seller) ->
    Prices = collect_prices(Seller, 2000),
    Diffs = collect_diffs(Prices),
    Seqs = collect_seqs(Diffs),
    lists:uniq(fun({Seq, _}) -> Seq end, Seqs).

collect_prices(_Secret, 0) -> [];
collect_prices(Secret, Left) ->
    Price = Secret rem 10,
    [Price | collect_prices(next_secret(Secret), Left - 1)].

collect_diffs([A, B | Prices]) ->
    [{B - A, B} | collect_diffs([B | Prices])];
collect_diffs([_]) -> [].

collect_seqs([{A,_} | [{B,_}, {C,_}, {D,Price} | _]=Diffs]) ->
    %% Optimization: compress the sequence to a small integer.
    Seq = lists:foldl(fun(E, Acc) ->
                              Acc * 20 + E + 10
                      end, 0, [A,B,C,D]),
    [{Seq, Price} | collect_seqs(Diffs)];
collect_seqs([_, _, _]) -> [].

next_secret(Secret0) ->
    Mask = 16777216 - 1,
    Secret1 = ((Secret0 bsl 6) bxor Secret0) band Mask,
    Secret = ((Secret1 bsr 5) bxor Secret1) band Mask,
    ((Secret bsl 11) bxor Secret) band Mask.

get_input() ->
    {ok,Input} = file:read_file("input.txt"),
    Lines = binary:split(Input, ~"\n", [global,trim]),
    [binary_to_integer(Line) || Line <- Lines].
