defmodule DistHash.Worker do

  @chunk_size 1_048_576
  
  def start_link do
    {:ok, self()}
  end

  def compute_hash(filepath, caller) do
    chunks = File.stream!(filepath, [], @chunk_size) |> Enum.map(&(&1))
    chunk_hash = Enum.reduce(chunks, :crypto.hash_init(:sha256), fn chunk, acc -> 
      :crypto.hash_update(acc, chunk)
    end)

    hash = :crypto.hash_final(chunk_hash) |> Base.encode16(case: :lower)

    send(caller, {:result, filepath, hash})
  end

end
