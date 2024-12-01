#!/usr/bin/env escript

main(_) ->
    Input = get_input(),
    io:format("Part 1: ~p\n", [part1(Input)]),
    io:format("Part 2: ~p\n", [part2(Input)]).

part1(Input0) ->
    {L1,L2} = lists:unzip(Input0),
    lists:sum(lists:zipwith(fun(A, B) ->
                                    abs(A - B)
                            end,
                            lists:sort(L1),
                            lists:sort(L2))).
    %% In OTP 28 the preceding expression can be replaced with:
    %% lists:sum([abs(A - B) ||
    %%               A <- lists:sort(L1) && B <- lists:sort(L2)]).

part2(Input0) ->
    {L1,L2} = lists:unzip(Input0),
    Gs = maps:groups_from_list(fun(I) -> I end, L2),
    lists:sum([A * length(maps:get(A, Gs, [])) || A <- L1]).

get_input() ->
    {ok,Input} = file:read_file("input.txt"),
    Lines = binary:split(Input, ~"\n", [global,trim]),
    [begin
         [A,B] = binary:split(Line, ~" ", [global,trim_all]),
         {binary_to_integer(A),
          binary_to_integer(B)}
     end || Line <- Lines].
