#!/usr/bin/env escript

-define(WIDTH, 101).
-define(HEIGHT, 103).

main(_) ->
    Input = get_input(),
    io:format("Part 1: ~p\n", [part1(Input)]),
    io:format("Part 2: ~p\n", [part2(Input)]).

part1(Robots) ->
    MidX = ?WIDTH div 2,
    MidY = ?HEIGHT div 2,
    L0 = [{mod(X + 100 * Dx, ?WIDTH),
           mod(Y + 100 * Dy, ?HEIGHT)} ||
             {{X, Y}, {Dx, Dy}} <- Robots],
    L1 = [{X, Y} || {X, Y} <- L0, X =/= MidX, Y =/= MidY],
    F = fun({X, Y}) ->
                {X div (MidX + 1), Y div (MidY + 1)}
        end,
    Gs = [length(Rs) || _ := Rs <- maps:groups_from_list(F, L1)],
    lists:foldl(fun erlang:'*'/2, 1, Gs).

part2(Robots) ->
    N = ?WIDTH * ?HEIGHT + 1,
    L = collect(1, N, Robots),
    Vs = [variance(Rs) || Rs <- L],

    %% We expect the variance of the positions to be lowest when the
    %% robots form an image.
    Z = lists:zipwith(fun(A, B) -> {A,B} end, Vs, lists:seq(1, N - 1)),
    {_, Seconds} = lists:min(Z),
    Seconds.

collect(N, N, _Robots) -> [];
collect(I, N, Robots0) ->
    Robots = [{{mod(X + Dx, ?WIDTH), mod(Y + Dy, ?HEIGHT)}, {Dx, Dy}} ||
                 {{X, Y}, {Dx, Dy}} <- Robots0],
    [Robots|collect(I + 1, N, Robots)].

variance(Robots) ->
    Ps = [X + Y || {{X, Y}, _} <- Robots],
    Mean = lists:sum(Ps) / length(Ps),
    Diffs = [begin
                 Diff = P - Mean,
                 Diff * Diff
             end || P <- Ps],
    lists:sum(Diffs) / length(Diffs).

mod(A, B) ->
    case A rem B of
        N when N < 0 -> mod(N + B, B);
        N -> N
    end.

get_input() ->
    {ok,Input} = file:read_file("input.txt"),
    Lines = binary:split(Input, ~"\n", [global,trim]),
    [begin
         [<<"p=",P/binary>>, <<"v=",V/binary>>] =
             binary:split(Line, ~" "),
         {parse_pair(P), parse_pair(V)}
     end || Line <- Lines].

parse_pair(S0) ->
    {A, <<",",S1/binary>>} = string:to_integer(S0),
    {A, binary_to_integer(S1)}.
