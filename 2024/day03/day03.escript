#!/usr/bin/env escript

main(_) ->
    Input = get_input(),
    io:format("Part 1: ~p\n", [part1(Input)]),
    io:format("Part 2: ~p\n", [part2(Input)]).

part1(Input) ->
    lists:sum([N || N <- parse(Input),
                    is_integer(N)]).

part2(Input) ->
    Ops0 = parse(Input),
    Ops = filter_ops(Ops0),
    lists:sum(Ops).

filter_ops([disable|T0]) ->
    T = lists:dropwhile(fun(E) -> E =/= enable end, T0),
    filter_ops(T);
filter_ops([enable|T]) ->
    filter_ops(T);
filter_ops([N|T]) when is_integer(N) ->
    [N|filter_ops(T)];
filter_ops([]) ->
    [].

parse(<<"don't()",T/binary>>) ->
    [disable|parse(T)];
parse(<<"do()",T/binary>>) ->
    [enable|parse(T)];
parse(<<"mul(",T0/binary>>) ->
    maybe
        {A,T1} ?= get_number(T0),
        <<",",T2/binary>> ?= T1,
        {B,T3} ?= get_number(T2),
        <<")",T4/binary>> ?= T3,
        [A * B | parse(T4)]
    else
        _ ->
            parse(T0)
    end;
parse(<<_,T/binary>>) ->
    parse(T);
parse(<<>>) ->
    [].

get_number(String) ->
    get_number(String, 0, 0).

get_number(<<D,T/binary>>, NumDigits, N)
  when NumDigits < 3, $0 =< D, D =< $9 ->
    get_number(T, NumDigits + 1, N * 10 + D - $0);
get_number(T, NumDigits, N) when 1 =< NumDigits, NumDigits =< 3 ->
    {N,T};
get_number(_, _, _) ->
    none.

get_input() ->
    {ok,Input} = file:read_file("input.txt"),
    Input.
