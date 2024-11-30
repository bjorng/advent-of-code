defmodule Day07 do

  def execute_lines lines, num_workers, base_step_time do
    lines
    |> Enum.map(&parse/1)
    |> init_relation_map
    |> execute(num_workers, base_step_time)
  end

  def top_sort_file file do
    File.stream!(file)
    |> Enum.map(&String.trim/1)
    |> top_sort_lines
  end

  def top_sort_lines lines do
    lines
    |> Enum.map(&parse/1)
    |> top_sort()
  end

  defp execute relations, num_workers, base_step_time do
    for _i <- 1..num_workers do
      {spawn(fn -> worker nil, 0 end), :idle}
    end
    |> execute_loop(relations, 0, base_step_time)
  end

  defp execute_loop workers, relations, time, base_step_time do
    idle = get_idle_workers workers
    ready = get_ready_tasks relations
    ready = Enum.reject(ready, fn task_name ->
      Enum.any?(workers, fn {_, state} ->
	case state do
	  {:busy, ^task_name} -> true
	  _ -> false
	end
      end)
    end)
    schedule_work idle, ready, base_step_time
    workers = tick workers
    time = time + 1
    relations = remove_finished relations, workers
    workers = Enum.map(workers, fn {worker, state} ->
      {worker, case state do
		 {:done, _} -> :idle
		 _ -> state
	       end}
    end)
    if map_size(relations) == 0 do
      time
    else
      execute_loop workers, relations, time, base_step_time
    end
  end

  defp remove_finished relations, workers do
    Enum.reduce(workers, relations,
      fn worker, acc ->
	case worker do
	  {_, {:done, task_name}} ->
	    remove_task acc, task_name
	  {_, _} ->
	    acc
	end
      end)
  end

  defp tick workers do
    Enum.map(workers,
      fn {worker, _} ->
	send worker, {self(), :tick}
	receive do
	  {:tock, state} ->
	    {worker, state}
	end
      end)
  end

  defp schedule_work [pid | pids], [task | tasks], base_step_time do
    task_time = hd(task) - ?@ + base_step_time
    send pid, {:schedule_work, task, task_time}
    schedule_work pids, tasks, base_step_time
  end

  defp schedule_work _, _, _ do
  end

  defp get_idle_workers workers do
    for {pid, :idle} <- workers, do: pid
  end

  defp worker task_name, units do
    receive do
      {pid, :tick} ->
	case units do
	  0 ->
	    send pid, {:tock, :idle}
	    worker task_name, units
	  1 ->
	    send pid, {:tock, {:done, task_name}}
	    worker nil, 0
	  _ ->
	    send pid, {:tock, {:busy, task_name}}
	    worker task_name, units - 1
	end
      {:schedule_work, task_name, units} ->
	worker task_name, units
    end
  end

  defp top_sort relations do
    relations
    |> init_relation_map
    |> do_top_sort()
  end

  defp init_relation_map relations do
    relations
    |> Enum.reduce(%{}, fn {j, k}, acc ->
      acc
      |> Map.update(j, {0, [k]}, fn {count, succ} -> {count, [k | succ]} end)
      |> Map.update(k, {1, []}, fn {count, succ} -> {count+1, succ} end)
    end)
  end

  defp do_top_sort relations do
    case get_first_task relations do
      nil ->
	[]
      name ->
	relations = remove_task relations, name
	name ++ do_top_sort(relations)
    end
  end

  defp get_first_task relations do
    relations
    |> Enum.filter(fn {_, {count, _}} -> count == 0 end)
    |> Enum.sort
    |> (fn sorted ->
      case sorted do
	[{name, _} | _] -> name
	[] -> nil
      end
    end).()
  end

  defp get_ready_tasks relations do
    relations
    |> Enum.filter(fn {_, {count, _}} -> count == 0 end)
    |> Enum.sort
    |> Enum.map(fn {name, _} -> name end)
  end

  defp remove_task relations, name do
    {_, {0, successors}} = Map.fetch relations, name
    Enum.reduce(successors, relations,
      fn succ, acc ->
	{count, succs} = Map.fetch! acc, succ
	Map.put acc, succ, {count-1, succs}
      end)
      |> Map.delete(name)
  end

  defp parse line do
    <<"Step ",j," must be finished before step ",k," can begin.">> = line
    {[j],[k]}
  end
end
