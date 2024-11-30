defmodule Day17 do
  def part1(input) do
    grid = read_grid(input)
    IO.write(grid)
    set = make_map_set(String.split(grid, "\n"))
    find_intersections(set)
  end

  def part2(input) do
    path = find_path(input)
    operate_robot(input, path)
  end

  # Part 1 helpers

  defp find_intersections(set) do
    set
    |> Enum.filter(fn pos -> is_intersection(pos, set) end)
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum
  end

  defp is_intersection(pos, set) do
    Enum.all?(Enum.reverse(directions()), fn dir ->
      vec_add(pos, dir) in set
    end)
  end

  defp directions() do
    [{0, 1}, {0, -1}, {-1, 0}, {1, 0}]
  end

  defp vec_add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  # Part 2 helpers

  # Find the path for the robot
  defp find_path(input) do
    grid = read_grid(input)
    map = make_map(String.split(grid, "\n"))
    {pos, dir} = Map.fetch!(map, :robot)
    path_finder = PathFinder.new(pos, dir, map)
    path = PathFinder.find_paths(path_finder)
    PathFinder.make_path(path, path_finder)
  end

  defp operate_robot(program, path) do
    memory = Intcode.new(program)
    memory = Map.put(memory, 0, 2)
    robot_program = robot_program(path)
    memory = Intcode.execute(memory)
    send_commands(robot_program, memory)
  end

  defp send_commands([cmd | cmds], memory) do
    {output, memory} = Intcode.get_output(memory)
    IO.write(output)
    IO.write(cmd)
    memory = Intcode.set_input(memory, cmd)
    memory = Intcode.resume(memory)
    send_commands(cmds, memory)
  end
  defp send_commands([], memory) do
    {output, _memory} = Intcode.get_output(memory)
    IO.write(Enum.filter(output, & &1 < 255))

    # Read out the amount of dust collected.
    List.last(output)
  end

  defp robot_program(path) do
    Splitter.split(path) ++ ['n\n']
  end

  defp read_grid(program) do
    memory = Intcode.new(program)
    memory = Intcode.execute(memory)
    {output, _memory} = Intcode.get_output(memory)
    to_string(output)
  end

  defp make_map_set(input) do
    input
    |> Stream.with_index
    |> Enum.reduce(MapSet.new(), fn {line, y}, set ->
      String.to_charlist(line)
      |> Stream.with_index
      |> Enum.reduce(set, fn {char, x}, set ->
	case char do
	  ?\# -> MapSet.put(set, {x, y})
	  ?\. -> set
	  _ -> set
	end
      end)
    end)
  end

  defp make_map(input) do
    input
    |> Stream.with_index
    |> Enum.reduce(Map.new(), fn {line, y}, map ->
      String.to_charlist(line)
      |> Stream.with_index
      |> Enum.reduce(map, fn {char, x}, map ->
	pos = {x, y}
	case char do
	  ?\# -> Map.put(map, pos, :path)
	  ?\. -> Map.put(map, {x, y}, :wall)
	  ?\^ ->
	    map = Map.put(map, :robot, {pos, {0, -1}})
	    Map.put(map, pos, :path)
	end
      end)
    end)
  end
end

defmodule Splitter do
  def split(prog) do
    main = pair(String.split(prog, ","))
    {:done, main, sub_progs} = split_program(main, ?A)
    [Enum.intersperse(main, ?\,) |
     Enum.map(sub_progs, fn sub_prog ->
       Enum.flat_map(sub_prog, fn {dir, amount} ->
	 [to_charlist(dir), to_charlist(amount)]
       end)
       |> Enum.intersperse(?\,)
       |> List.flatten
     end)]
     |> Enum.map(& &1 ++ '\n')
  end

  defp pair([dir, amount | tail]) do
    [{dir, amount} | pair(tail)]
  end
  defp pair([]), do: []

  defp split_program(main, sub_prog_id) do
    find_start(main, sub_prog_id, [])
  end

  defp find_start([{_,_} | _] = main, sub_prog_id, acc) do
    build_sub_prog(main, 1, sub_prog_id, acc)
  end
  defp find_start([prog | tail], sub_prog_id, acc) do
    find_start(tail, sub_prog_id, [prog | acc])
  end
  defp find_start([], _sub_prog_id, acc) do
    if length(acc) <= 10 do
      {:done, Enum.reverse(acc), []}
    else
      {:error, :too_long_main_prog}
    end
  end

  defp build_sub_prog(main, len, sub_prog_id, acc) when sub_prog_id <= ?C do
    case take_sub_prog(main, len) do
      {:error, _} = error ->
	error
      sub_prog ->
	subst_main = subst_sub_prog(main, sub_prog, sub_prog_id)
	case split_program(subst_main, sub_prog_id + 1) do
	  {:error, _} ->
	    # Try to make this sub program longer.
	    build_sub_prog(main, len + 1, sub_prog_id, acc)
	  {:done, main, sub_progs} ->
	    {:done, Enum.reverse(acc, main), [sub_prog | sub_progs]}
	end
    end
  end
  defp build_sub_prog(_, _, _, _) do
    # There are already three sub programs. Can't start another.
    {:error, :too_many_sub_programs}
  end

  defp take_sub_prog(main, n, acc \\ [])
  defp take_sub_prog(_main, 0, acc) do
    case prog_len(acc) > 20 do
      true -> {:error, :too_long_sub_program}
      false -> Enum.reverse(acc)
    end
  end
  defp take_sub_prog([{_, _} = head | tail], n, acc) do
    take_sub_prog(tail, n - 1, [head | acc])
  end
  defp take_sub_prog(_, _, _), do: {:error, :sub_prog_cannot_grow}

  defp prog_len(sub_prog, len \\ -1)
  defp prog_len([{_,num} | tail], len) do
    prog_len(tail, len + byte_size(num) + 1 + 1)
  end
  defp prog_len([], len), do: len

  defp subst_sub_prog([head | tail] = main, sub_prog, sub_prog_id) do
    case List.starts_with?(main, sub_prog) do
      true ->
	main = Enum.drop(main, length(sub_prog))
	[sub_prog_id | subst_sub_prog(main, sub_prog, sub_prog_id)]
      false ->
	[head | subst_sub_prog(tail, sub_prog, sub_prog_id)]
    end
  end
  defp subst_sub_prog([], _, _), do: []
end

defmodule PathFinder do
  defstruct pos: nil, dir: nil, map: nil

  def new(pos, dir, map) do
    %PathFinder{pos: pos, dir: dir, map: map}
  end

  def make_path([pos | path], path_finder) do
    ^pos = path_finder.pos		# Assertion.
    path = do_make_path(path, pos, path_finder.dir, [])
    robotize(path)
  end

  defp robotize(path) do
    path
    |> Enum.map(fn cmd ->
      case cmd do
	:left -> "L"
	:right -> "R"
	int when is_integer(int) -> to_string(int)
      end
    end)
    |> Enum.intersperse(",")
    |> to_string
  end

  def do_make_path([next | path], pos, dir, acc) do
    {acc, dir} = maybe_turn(next, pos, dir, acc)
    ^next = vec_add(pos, dir)	# Assertion
    acc = move_one(acc)
    do_make_path(path, next, dir, acc)
  end
  def do_make_path([], _, _, acc), do: Enum.reverse(acc)

  defp maybe_turn(next, pos, dir, acc) do
    case vec_add(pos, dir) do
      ^next -> {acc, dir}
      _ ->
	case vec_add(pos, turn_right(dir)) do
	  ^next ->
	    ^next = vec_add(pos, turn_right(dir)) # Assertion.
	    {[:right | acc], turn_right(dir)}
	  _ ->
	    case vec_add(pos, turn_left(dir)) do
	      ^next ->
		^next = vec_add(pos, turn_left(dir)) # Assertion.
                {[:left | acc], turn_left(dir)}
	      _ ->
		^next = vec_add(pos, turn_around(dir)) # Assertion.
                {[:right, :right | acc], turn_around(dir)}
	    end
	end
    end
  end

  defp move_one([cmd | acc]) do
    case is_integer(cmd) do
      true ->
	[cmd + 1 | acc]
      false ->
	[1, cmd | acc]
    end
  end
  defp move_one([]), do: [1]

  def find_paths(path_finder) do
    paths = [init_path(path_finder)]
    find_paths(paths, path_finder)
  end

  defp find_paths(paths, path_finder) do
    paths = extend_paths(paths, path_finder)
    case Enum.find(paths, &all_visited?/1) do
      nil -> find_paths(paths, path_finder)
      path -> get_path(path)
    end
  end

  defp extend_paths([path | paths], path_finder) do
    paths1 = directions(path)
    |> Enum.flat_map(fn dir ->
      extend_path(path, dir, path_finder)
    end)
    paths2 = extend_paths(paths, path_finder)
    paths1 ++ paths2
  end
  defp extend_paths([], _path_finder), do: []

  defp extend_path(path, dir, path_finder) do
    pos = get_pos(path)
    new_pos = vec_add(pos, dir)
    not_wall = Map.get(path_finder.map, new_pos, :wall) == :path
    unvisited = unvisited?(new_pos, dir, path)
    if not_wall and unvisited do
      [visit(pos, dir, path)]
    else
      []
    end
  end

  defp init_path(path_finder) do
    pos = path_finder.pos
    unvisited = path_finder.map
    |> Stream.flat_map(fn
      {pos, :path} -> [pos]
      {_, _} -> []
    end)
    |> MapSet.new
    unvisited = MapSet.delete(unvisited, pos)

    visited = Enum.map(directions(), & {pos, &1})
    |> MapSet.new

    {[pos], visited, unvisited}
  end

  defp get_pos({[pos | _], _, _}), do: pos
  defp get_path({path, _, _}), do: Enum.reverse(path)

  defp all_visited?({_path, _visited, unvisited}) do
    MapSet.size(unvisited) === 0
  end

  defp unvisited?(new_pos, from_dir, {_path, visited, _unvisited}) do
    not MapSet.member?(visited, {new_pos, from_dir})
  end

  defp visit(pos, from_dir, {path, visited, unvisited}) do
    new_pos = vec_add(pos, from_dir)
    visited = MapSet.put(visited, {pos, turn_around(from_dir)})
    visited = MapSet.put(visited, {new_pos, from_dir})
    unvisited = MapSet.delete(unvisited, new_pos)
    {[new_pos | path], visited, unvisited}
  end

  defp directions() do
    [{0, 1}, {0, -1}, {-1, 0}, {1, 0}]
  end

  defp directions({path, _, _}) do
    case path do
      [pos1, pos2 | _ ] ->
	# Prefer to continue moving in the same direction
	# to make the path as short as possible.
	dir = vec_sub(pos1, pos2)
	[dir, turn_left(dir), turn_right(dir), turn_around(dir) ]
      _ ->
	directions()
    end
  end

  # Note: Y axis is reversed; left is right and right is left.
  defp turn_left({dx, dy}), do: {dy, -dx}
  defp turn_right({dx, dy}), do: {-dy, dx}
  defp turn_around({dx, dy}), do: {-dx, -dy}

  defp vec_add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
  defp vec_sub({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}
end

defmodule Intcode do
  def new(program) do
    machine(program)
  end

  defp machine(input) do
    memory = read_program(input)
    memory = Map.put(memory, :ip, 0)
    Map.put(memory, :output, :queue.new())
  end

  def set_input(memory, input) do
    Map.put(memory, :input, input)
  end

  def get_output(memory) do
    q = Map.fetch!(memory, :output)
    Map.put(memory, :output, :queue.new())
    {:queue.to_list(q), memory}
  end

  def resume(memory) do
    execute(memory, Map.fetch!(memory, :ip))
  end

  def execute(memory, ip \\ 0) do
    {opcode, modes} = fetch_opcode(memory, ip)
    case opcode do
      1 ->
	memory = exec_arith_op(&+/2, modes, memory, ip)
	execute(memory, ip + 4)
      2 ->
	memory = exec_arith_op(&*/2, modes, memory, ip)
	execute(memory, ip + 4)
      3 ->
	case exec_input(modes, memory, ip) do
	  {:suspended, memory} ->
	    memory
	  memory ->
	    execute(memory, ip + 2)
	end
      4 ->
	memory = exec_output(modes, memory, ip)
	execute(memory, ip + 2)
      5 ->
	ip = exec_if(&(&1 !== 0), modes, memory, ip)
	execute(memory, ip)
      6 ->
	ip = exec_if(&(&1 === 0), modes, memory, ip)
	execute(memory, ip)
      7 ->
	memory = exec_cond(&(&1 < &2), modes, memory, ip)
	execute(memory, ip + 4)
      8 ->
	memory = exec_cond(&(&1 === &2), modes, memory, ip)
	execute(memory, ip + 4)
      9 ->
	memory = exec_inc_rel_base(modes, memory, ip)
	execute(memory, ip + 2)
      99 ->
	memory
    end
  end

  defp exec_arith_op(op, modes, memory, ip) do
    [in1, in2] = read_operand_values(memory, ip + 1, modes, 2)
    out_addr = read_out_address(memory, div(modes, 100), ip + 3)
    result = op.(in1, in2)
    write(memory, out_addr, result)
  end

  defp exec_input(modes, memory, ip) do
    out_addr = read_out_address(memory, modes, ip + 1)
    case Map.get(memory, :input, []) do
      [] ->
	{:suspended, Map.put(memory, :ip, ip)}
      [value | input] ->
        memory = write(memory, out_addr, value)
	Map.put(memory, :input, input)
    end
  end

  defp exec_output(modes, memory, ip) do
    [value] = read_operand_values(memory, ip + 1, modes, 1)
    q = Map.fetch!(memory, :output)
    q = :queue.in(value, q)
    Map.put(memory, :output, q)
  end

  defp exec_if(op, modes, memory, ip) do
    [value, new_ip] = read_operand_values(memory, ip + 1, modes, 2)
    case op.(value) do
      true -> new_ip
      false -> ip + 3
    end
  end

  defp exec_cond(op, modes, memory, ip) do
    [operand1, operand2] = read_operand_values(memory, ip + 1, modes, 2)
    out_addr = read_out_address(memory, div(modes, 100), ip + 3)
    result = case op.(operand1, operand2) do
	       true -> 1
	       false -> 0
	     end
    write(memory, out_addr, result)
  end

  defp exec_inc_rel_base(modes, memory, ip) do
    [offset] = read_operand_values(memory, ip + 1, modes, 1)
    base = get_rel_base(memory) + offset
    Map.put(memory, :rel_base, base)
  end

  defp read_operand_values(_memory, _addr, _modes, 0), do: []
  defp read_operand_values(memory, addr, modes, n) do
    operand = read(memory, addr)
    operand = case rem(modes, 10) do
		0 -> read(memory, operand)
		1 -> operand
		2 -> read(memory, operand + get_rel_base(memory))
	      end
    [operand | read_operand_values(memory, addr + 1, div(modes, 10), n - 1)]
  end

  defp read_out_address(memory, modes, addr) do
    out_addr = read(memory, addr)
    case modes do
      0 -> out_addr
      2 -> get_rel_base(memory) + out_addr
    end
  end

  defp fetch_opcode(memory, ip) do
    opcode = read(memory, ip)
    modes = div(opcode, 100)
    opcode = rem(opcode, 100)
    {opcode, modes}
  end

  defp get_rel_base(memory) do
    Map.get(memory, :rel_base, 0)
  end

  defp read(memory, addr) do
    Map.get(memory, addr, 0)
  end

  defp write(memory, addr, value) do
    Map.put(memory, addr, value)
  end

  defp read_program(input) do
    String.split(input, ",")
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index
    |> Stream.map(fn {code, index} -> {index, code} end)
    |> Map.new
  end
end
