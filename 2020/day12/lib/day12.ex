defmodule Day12 do
  def part1(input) do
    ship = {0, 0}
    direction = 1
    parse(input)
    |> Enum.reduce({ship, direction}, &execute_part1/2)
    |> distance
  end

  def part2(input) do
    ship = {0, 0}
    waypoint = {10, 1}
    parse(input)
    |> Enum.reduce({ship, waypoint}, &execute_part2/2)
    |> distance
  end

  defp execute_part1({command, amount} = cmd, {location, direction}) do
    case command do
      :F -> {forward(location, direction, amount), direction}
      :L -> {location, turn_right(direction, -amount)}
      :R -> {location, turn_right(direction, amount)}
      _direction -> {execute_direction(cmd, location), direction}
    end
  end

  defp execute_part2({command, amount} = cmd, {ship, waypoint}) do
    case command do
      :F ->
        offset = vec_sub(waypoint, ship)
        ship = vec_add(ship, vec_mul(amount, offset))
        waypoint = vec_add(ship, offset)
        {ship, waypoint}
      :L ->
        {ship, rot_around(waypoint, amount, ship)}
      :R ->
        {ship, rot_around(waypoint, -amount, ship)}
      _ ->
        {ship, execute_direction(cmd, waypoint)}
    end
  end

  defp execute_direction({command, amount}, location) do
    case command do
      :N -> forward(location, 0, amount)
      :E -> forward(location, 1, amount)
      :S -> forward(location, 2, amount)
      :W -> forward(location, 3, amount)
    end
  end

  defp forward({x, y}, direction, amount) do
    case direction do
      0 -> {x, y + amount}
      2 -> {x, y - amount}
      1 -> {x + amount, y}
      3 -> {x - amount, y}
    end
  end

  defp vec_add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  defp vec_mul(scalar, {x, y}), do: {scalar * x, scalar * y}

  defp vec_sub({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}

  defp rot_around(point, amount, around) do
    point
    |> vec_sub(around)
    |> rot_ccw(amount)
    |> vec_add(around)
  end

  defp rot_ccw(point, amount) do
    amount = div(amount, 90)
    amount = if (amount < 0), do: 4 + amount, else: amount
    Enum.reduce(1..amount, point, fn _, point ->
      rot90_ccw(point)
    end)
  end

  defp rot90_ccw({x, y}), do: {-y, x}

  defp turn_right(direction, amount) do
    rem(4 + direction + div(amount, 90), 4)
  end

  defp distance({{x, y}, _}) do
    abs(x) + abs(y)
  end

  def parse(input) do
    Enum.map(input, fn line ->
      {command, amount} = String.split_at(line, 1)
      {String.to_atom(command), String.to_integer(amount)}
    end)
  end
end
