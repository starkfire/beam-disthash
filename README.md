# DistHash

**Distributed checksum computations in BEAM/Elixir**

## Overview

This is just a quick demonstration for leveraging BEAM/Elixir to distribute SHA-256 file checksum calculations (multiple files) to worker nodes.

Nodes can be created directly through IEx:

```sh
iex --sname node1 -S mix
```

A node can be defined as a **master node** using `DistHash.Master`:

```elixir
DistHash.Master.start_link()
```

**Worker nodes** can be defined using `DistHash.Worker`:

```elixir
DistHash.Worker.start_link()
```

Within the Master node, you can provide the filepaths and names of your worker nodes to `DistHash.Master.calculate/2`:

```elixir
filepaths = ["slides.pdf", "exam.pdf"]
workers = [:node2@local, :node3@local]

DistHash.Master.calculate(filepaths, workers)
```

To test how fast the calculation process goes in microseconds, you can use Erlang's `timer.tc/1`:

```elixir
{time_microseconds, ret_val} = :timer.tc(fn -> 
    DistHash.Master.calculate(filepaths, workers) 
end)
```

Checksum calculation in this demo is done by breaking files into 1 MB chunks. Thus, one way you can compare the results generated from this project would be to perform manual checksum calculations:

```elixir
{time_ms, ret_val} = :timer.tc(fn ->
  chunks = File.stream!("slides.pdf", [], 1_048_576) |> Enum.map(&(&1))
  chunk_hash = Enum.reduce(chunks, :crypto.hash_init(:sha256), fn chunk, acc -> 
    :crypto.hash_update(acc, chunk)
  end)
  hash = :crypto.hash_final(chunk_hash) |> Base.encode16(case: :lower)
end)

IO.puts time_ms
```

Another way would be to perform manual checksum calculations without chunking:

```elixir
{time_ms, ret_val} = :timer.tc(fn ->
    :crypto.hash(:sha256, File.read!("slides.pdf")) |> Base.encode16(case: :lower)
end)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `disthash` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:disthash, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/disthash>.

