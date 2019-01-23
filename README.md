# DbgInspect

dbg_inspect provides `Dbg.inspect/2` macro, which is an extended version of `IO.inspect/1` function for the debug purposes.

## Additional Features

* Prints representation of expression passed as the first argument
* Prints file name and line number where `Dbg.inspect/2` was called
* Ability to print values of all variables used in the expression passed as the first argument
* Colored output
* Output to :stderr stream
* No affects `prod` environment


## Example

```elixir
  list = [1, 2, 3]
  zero = 0

  list
  |> Enum.map(&{&1, to_string(&1 * &1)})
  |> Enum.into(%{})
  |> Map.put(zero, to_string(zero))
  |> Dbg.inspect(show_vars: true)
```
![output](https://raw.githubusercontent.com/romul/dbg_inspect/master/example.png)

## Installation

The package can be installed by adding `dbg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dbg_inspect, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/dbg](https://hexdocs.pm/dbg_inspect).

