#!/usr/bin/env escript

main(_) ->
    Input = get_input(),
    io:format("Part 1: ~p\n", [part1(Input)]),
    io:format("Part 2: ~p\n", [part2(Input)]).

part1(Input) ->
    length([true || Levels <- Input, is_safe(Levels)]).

part2(Input) ->
    safe_levels(Input, 0).

safe_levels([Levels|Reports], N) ->
    case damp(Levels, []) of
        true ->
            safe_levels(Reports, N + 1);
        false ->
            safe_levels(Reports, N)
    end;
safe_levels([], N) ->
    N.

damp([Level|Levels], Prefix) ->
    is_safe(lists:reverse(Levels, Prefix)) orelse
        damp(Levels, [Level|Prefix]);
damp([], Prefix) ->
    is_safe(Prefix).

is_safe([A,A|_]) ->
    false;
is_safe([A,B|T]) ->
    Diff = A - B,
    is_safe(A, [B|T], Diff div abs(Diff)).

is_safe(A, [B|T], Sign) ->
    Diff = Sign * (A - B),
    if
        1 =< Diff, Diff =< 3 ->
            is_safe(B, T, Sign);
        true ->
            false
    end;
is_safe(_, [], _) ->
    true.

get_input() ->
    {ok,Input} = file:read_file("input.txt"),
    Lines = binary:split(Input, ~"\n", [global,trim]),
    [begin
         Ints = binary:split(Line, ~" ", [global,trim_all]),
         [binary_to_integer(I) || I <- Ints]
     end || Line <- Lines].
