#
# I stumbled with collision detection for a long time (I didn't
# detect some collisions). What follows is the cleaned up version
# of my code, not the first version that returned the correct answer.
#

defmodule Day13 do
  def part1 lines do
    chart = make_chart lines
    {carts, chart} = remove_carts chart
    {_, [collision | _]} = find_collisions carts, chart
    collision
  end

  def part2 lines do
    chart = make_chart lines
    {carts, chart} = remove_carts chart
    {remaining_cart, _} = find_collisions carts, chart
    remaining_cart
  end

  defp find_collisions carts, chart do
    find_collisions carts, chart, []
  end

  defp find_collisions [], _chart, collisions do
    {nil, Enum.reverse(collisions)}
  end

  defp find_collisions [{pos, _, _}], _chart, collisions do
    {pos, Enum.reverse(collisions)}
  end

  defp find_collisions carts, chart, collisions do
    carts = Enum.sort_by([_ | _] = carts, fn {{x, y}, _, _} -> {y, x} end)
    {carts, collisions} = find_collisions carts, chart, [], collisions
    find_collisions carts, chart, collisions
  end

  defp find_collisions [cart | carts], chart, cart_acc, collisions do
    cart = move_cart cart, chart
    case find_collision(cart, carts) do
      nil ->
	case find_collision(cart, cart_acc) do
	  nil ->
	    find_collisions carts, chart, [cart | cart_acc], collisions
	  cart_acc ->
	    find_collisions carts, chart, cart_acc, [elem(cart, 0) | collisions]
	end
      carts ->
	find_collisions carts, chart, cart_acc, [elem(cart, 0) | collisions]
    end
  end

  defp find_collisions [], _chart, cart_acc, collisions do
    {cart_acc, collisions}
  end

  defp find_collision(cart, carts), do: find_collision(cart, carts, [])

  defp find_collision {pos, _, _}, [{pos, _, _} | carts], acc do
    Enum.reverse(acc, carts)
  end

  defp find_collision cart, [other_cart | carts], acc do
    find_collision cart, carts, [other_cart | acc]
  end

  defp find_collision _cart, [], _acc do
    nil
  end

  defp move_cart {pos, dir, turn}, chart do
    pos = add pos, dir
    case at(chart, pos) do
      ?+ ->
	turn_cart(pos, dir, turn)
      ?- ->
	{pos, dir, turn}
      ?| ->
	{pos, dir, turn}
      ?/ ->
	{pos, case dir do
		0 -> 90
		90 -> 0
		180 -> 270
		270 -> 180
	      end, turn}
      ?\\ ->
	{pos, case dir do
		0 -> 270
		270 -> 0
		90 -> 180
		180 -> 90
	      end, turn}
    end
  end

  defp turn_cart pos, direction, turn do
    case turn do
      :left ->
	{pos, normalize_angle(direction + 90), :straight}
      :straight ->
	{pos, direction, :right}
      :right ->
	{pos, normalize_angle(direction - 90), :left}
    end
  end

  defp normalize_angle angle do
    rem(angle+360, 360)
  end

  defp add({x, y}, angle) do
    case angle do
      0 -> {x + 1, y}
      180 -> {x - 1, y}
      90 -> {x, y - 1}
      270 -> {x, y + 1}
    end
  end

  defp at(chart, {x, y}) do
    <<_::binary-size(x), char, _::binary>> = chart[y]
    char
  end

  defp make_chart lines do
    Enum.zip(0..length(lines)-1, lines)
    |> Enum.into(%{})
  end

  defp remove_carts chart do
    Enum.reduce(chart, {[], chart},
      fn {y, line}, {carts, chart} ->
	{line, carts} = remove_cart_from_line line, 0, y, <<>>, carts
	chart = %{chart | y => line}
	{carts, chart}
      end)
  end

  defp remove_cart_from_line <<h, t::binary>>, x, y, line, carts do
    case h do
      ?> ->
	cart = {{x, y}, 0, :left}
	remove_cart_from_line t, x + 1, y, <<line::binary, "-">>, [cart | carts]
      ?< ->
	cart = {{x, y}, 180, :left}
	remove_cart_from_line t, x + 1, y, <<line::binary, "-">>, [cart | carts]
      ?^ ->
	cart = {{x, y}, 90, :left}
	remove_cart_from_line t, x + 1, y, <<line::binary, "|">>, [cart | carts]
      ?v ->
	cart = {{x, y}, 270, :left}
	remove_cart_from_line t, x + 1, y, <<line::binary, "|">>, [cart | carts]
      _ ->
	remove_cart_from_line t, x + 1, y, <<line::binary, h>>, carts
    end
  end

  defp remove_cart_from_line <<>>, _x, _y, line, carts do
    {line, carts}
  end

  def print chart, carts do
    IO.puts ""
    IO.inspect carts
    insert_carts(carts, chart)
    |> Enum.to_list
    |> Enum.sort
    |> Enum.each(fn {_, line} -> IO.puts line end)
  end

  def insert_carts carts, chart do
    Enum.reduce(carts, chart,
      fn {{x, y}, dir, _}, chart ->
	dir_char = case dir do
		     0 -> ?>;
		     180 -> ?<;
		     90 -> ?^;
		     270 -> ?v;
		   end
	line = chart[y]
	<<bef::binary-size(x), _, aft::binary>> = line
	line = <<bef::binary, dir_char, aft::binary>>
	%{chart | y => line}
      end)
  end

end
