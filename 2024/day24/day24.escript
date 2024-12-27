#!/usr/bin/env escript

main(_) ->
    Input = get_input(),
    io:format("Part 1: ~p\n", [part1(Input)]),
    io:format("Part 2: ~p\n", [part2(Input)]).

part1({Inputs, Gates}) ->
    Map = maps:from_list(Inputs ++ Gates),
    ZWires = [Wire || {{z, _}=Wire, _} <- Gates],
    lists:sum([eval(Wire, Map) bsl Bit || {z,Bit}=Wire <- ZWires]).

eval({Op, [_,_]=Args}, Map) when is_atom(Op) ->
    [In1, In2] = [eval(Arg, Map) || Arg <- Args],
    case Op of
        'AND' -> In1 band In2;
        'OR' -> In1 bor In2;
        'XOR' -> In1 bxor In2
    end;
eval(Val, _Map) when is_integer(Val) ->
    Val;
eval(In, Map) ->
    eval(map_get(In, Map), Map).

%%%
%%% The inspiration for the algorithm for solving part 2 is from Liam
%%% Mitchell's (@liamcmitchell) solution in the Elixir forum.
%%%

part2({_Inputs, Gates}) ->
    Zs = lists:sort([Output || {{z, _}=Output, _} <- Gates]),
    {Swapped0, _} = lists:foldl(fun fix_outputs/2, {[], maps:from_list(Gates)}, Zs),
    Swapped = [format_wire(Wire) || Wire <- Swapped0],
    lists:append(lists:join(",", lists:sort(Swapped))).

fix_outputs({z, Bit}=Wire, {Swapped, Gates0}) ->
    Expected = adder(Bit),
    case construct_tree(Gates0, Wire) of
        Expected ->
            {Swapped, Gates0};
        Actual ->
            Wires = #{construct_tree(Gates0, W) => W ||
                        W <- maps:keys(Gates0)},
            case find_swap(Wires, Expected, Actual) of
                none ->
                    {Swapped, Gates0};
                {A, B} ->
                    io:format("bit ~p: swapping ~s and ~s\n",
                              [Bit | [format_wire(W) || W <- [A, B]]]),
                    #{A := GateA, B := GateB} = Gates0,
                    Gates = Gates0#{A => GateB, B => GateA},
                    {[A, B | Swapped], Gates}
            end
    end.

find_swap(Wires, Expected, Actual) ->
    case Wires of
        #{Expected := A} ->
            {A, map_get(Actual, Wires)};
        #{} ->
            {_, [E1, E2]} = Expected,
            {_, [A1, A2]} = Actual,
            case {E1, E2, A1, A2} of
                {Same, E, Same, A} ->
                    find_swap(Wires, E, A);
                {Same, E, A, Same} ->
                    find_swap(Wires, E, A);
                {E, Same, Same, A} ->
                    find_swap(Wires, E, A);
                {E, Same, A, Same} ->
                    find_swap(Wires, E, A);
                _ ->
                    %% Can only happen for the highest numbered z output.
                    none
            end
    end.

%% Construct the expected logical operations for the adder. We don't
%% bother handling the highest z output (z45 in my input), which is
%% carry with no corresponding x and y inputs. It is instead handled
%% in find_swap/3.
adder(0) ->
    op('XOR', [{x,0}, {y,0}]);
adder(Bit) ->
    op('XOR', [op('XOR', [{x,Bit}, {y,Bit}]), remainder(Bit - 1)]).

remainder(0) ->
    op('AND', [{x,0}, {y,0}]);
remainder(Bit) ->
    XY = [{x,Bit}, {y,Bit}],
    op('OR',
       [op('AND', XY),
        op('AND',
           [op('XOR', XY),
            remainder(Bit - 1)])]).

op(Op, Args) ->
    {Op, lists:sort(Args)}.

construct_tree(Gates, Wire) ->
    case Gates of
        #{Wire := {Op, [A, B]}} ->
            op(Op, [construct_tree(Gates, A),
                    construct_tree(Gates, B)]);
        #{} ->
            Wire
    end.

format_wire(Wire) ->
    case Wire of
        {Type, N} ->
            [hd(atom_to_list(Type)), N div 10 + $0, N rem 10 + $0];
        _ ->
            atom_to_list(Wire)
    end.

get_input() ->
    {ok,InputData} = file:read_file("input.txt"),
    [Inputs0, Gates0] = binary:split(InputData, ~"\n\n", [trim]),
    Inputs = [begin
                  [Input,Value] = binary:split(Line, ~": "),
                  {parse_wire(Input), binary_to_integer(Value)}
              end || Line <- binary:split(Inputs0, ~"\n", [global,trim_all])],
    Gates = [begin
                 [In1, Op, In2, ~"->", Out] =
                     binary:split(Line, ~" ", [global,trim_all]),
                 Operands = lists:sort([parse_wire(In1), parse_wire(In2)]),
                 {parse_wire(Out), {binary_to_atom(Op), Operands}}
             end || Line <- binary:split(Gates0, ~"\n", [global,trim_all])],
    {Inputs, Gates}.

parse_wire(<<Type, N/binary>>) when Type =:= $x;
                                    Type =:= $y;
                                    Type =:= $z ->
    {list_to_atom([Type]), binary_to_integer(N)};
parse_wire(Wire) ->
    binary_to_atom(Wire).
