defmodule Day07 do
  def part1(input) do
    parse(input)
    |> directory_sizes
    |> Enum.filter(&(elem(&1, 1) <= 100_000))
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.sum
  end

  defp directory_sizes(tree) do
    %{"/" => tree} = tree
    directory_sizes("/", tree, [], %{})
  end

  defp directory_sizes(dir_name, tree, path, sizes) do
    path = [dir_name | path]
    {size, sizes} = Enum.reduce(tree, {0, sizes},
      fn {name, item}, {size, sizes} ->
        cond do
          is_map(item) ->
            sizes = directory_sizes(name, item, path, sizes)
            {size + Map.get(sizes, [name | path]), sizes}
          is_integer(item) ->
            {size + item, sizes}
        end
      end)
    Map.put(sizes, path, size)
  end

  def part2(input) do
    sizes = parse(input)
    |> directory_sizes

    total = 70_000_000
    must_have = 30_000_000
    used = Map.get(sizes, ["/"])
    unused = total - used
    need = must_have - unused

    sizes
    |> Enum.filter(&(elem(&1, 1) >= need))
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.min
  end

  defp parse(input) do
    input
    |> parse_commands
    |> make_tree
  end

  defp parse_commands(["$ " <> command | lines]) do
    {output, lines} =
      Enum.split_while(lines, fn
        "$" <> _ -> false
        _ -> true
      end)
    [command | arguments] = String.split(command)
    [{command, arguments, output} | parse_commands(lines)]
  end
  defp parse_commands([]), do: []

  defp make_tree(commands) do
    path = []
    tree = %{"/" => %{}}
    {_, tree} = Enum.reduce(commands, {path, tree}, &make_tree_cmd/2)
    tree
  end

  defp make_tree_cmd({command, arguments, output}, {path, tree}) do
    case command do
      "cd" ->
        case arguments do
          [".."] ->
            {tl(path), tree}
          [dir] ->
            {[dir | path], tree}
        end
      "ls" ->
        dir = dir_from_ls_output(output)
        {path, put_dir(path, tree, dir)}
    end
  end

  defp dir_from_ls_output(output) do
    Enum.reduce(output, %{},
      fn line, dir ->
        case String.split(line) do
          ["dir", name] ->
            Map.put(dir, name, %{})
          [size, name] ->
            size = String.to_integer(size)
            Map.put(dir, name, size)
        end
      end)
  end

  defp put_dir(path, tree, dir) do
    do_put_dir(Enum.reverse(path), tree, dir)
  end

  defp do_put_dir([], tree, dir) do
    Map.merge(tree, dir)
  end
  defp do_put_dir([name | path], tree, dir) do
    %{^name => contents} = tree
    %{tree | name => do_put_dir(path, contents, dir)}
  end
end
