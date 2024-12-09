defmodule DistHash.Master do
  
  def start_link do
    {:ok, self()}
  end

  def distribute(filepaths, workers) do
    tasks = Enum.map(filepaths, fn filepath -> 
      worker = Enum.random(workers)

      Task.async(fn -> 
        :rpc.call(worker, DistHash.Worker, :compute_hash, [filepath, self()])
      end)
    end)

    tasks 
    |> Enum.map(&Task.await(&1, 5000))
    |> Enum.reduce([], fn {_, filepath, hash}, acc -> 
      [{filepath, hash} | acc]
    end)
  end

  def calculate(filepaths, workers) do
    worker_nodes = Enum.filter(workers, &Node.connect/1)
    distribute(filepaths, worker_nodes)
  end

end
