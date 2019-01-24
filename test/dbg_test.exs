defmodule DbgTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  require Dbg

  def dbg_inspect(fun) do
    capture_io(:stderr, fun)
    |> String.replace("\e[41m\e[1m\e[K\n", "")
    |> String.replace("\e[K\n\e[0m\n", "")
    |> String.replace("\e[K", "")
    |> String.split("\n")
  end

  test "inspect of a simple var" do
    fun = fn ->
      x = 7
      Dbg.inspect(x)
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:17",
             "  x #=> 7"
           ]
  end

  test "inspect of a simple expression" do
    fun = fn ->
      x = 7
      y = 5
      Dbg.inspect(x + y)
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:30",
             "  x + y #=> 12"
           ]
  end

  test "inspect of a regular expression" do
    fun = fn ->
      x = 7

      (x + 5)
      |> to_string
      |> String.to_integer()
      |> Dbg.inspect()
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:46",
             "  (x + 5)",
             "  |> to_string",
             "  |> String.to_integer() #=> 12"
           ]
  end

  test "inspect of an expression with more complex result" do
    fun = fn ->
      list = [1, 2, 3]

      list
      |> Enum.map(&{&1, to_string(&1 * &1)})
      |> Enum.into(%{})
      |> Dbg.inspect()
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:64",
             "  list",
             "  |> Enum.map(&{&1, to_string(&1 * &1)})",
             "  |> Enum.into(%{}) #=> %{1 => \"1\", 2 => \"4\", 3 => \"9\"}"
           ]
  end

  test "inspect in the middle of pipeline" do
    fun = fn ->
      x = 7

      (x + 5)
      |> to_string
      |> Dbg.inspect()
      |> String.to_integer()
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:81",
             "  (x + 5)",
             "  |> to_string #=> \"12\""
           ]
  end

  test "inspect with show_vars option" do
    fun = fn ->
      x = 7
      y = 5
      Dbg.inspect(x + y, show_vars: true)
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:96",
             "  x = 7",
             "  y = 5",
             "  x + y #=> 12"
           ]
  end

  test "inspect of an expression with more complex result and show_vars on" do
    fun = fn ->
      list = [1, 2, 3]

      list
      |> Enum.map(&{&1, to_string(&1 * &1)})
      |> Enum.into(%{})
      |> Dbg.inspect(show_vars: true)
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:114",
             "  list = [1, 2, 3]",
             "  list",
             "  |> Enum.map(&{&1, to_string(&1 * &1)})",
             "  |> Enum.into(%{}) #=> %{1 => \"1\", 2 => \"4\", 3 => \"9\"}"
           ]
  end

  test "inspect of a very long expression with show_vars on" do
    fun = fn ->
      list = [1, 2, 3]
      zero = 0

      list
      |> Enum.map(&{&1, to_string(&1 * &1)})
      |> Enum.into(%{})
      |> Map.put(zero, to_string(zero))
      |> Dbg.inspect(show_vars: true)
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:135",
             "  list = [1, 2, 3]",
             "  zero = 0",
             "  list",
             "  |> Enum.map(&{&1, to_string(&1 * &1)})",
             "  |> Enum.into(%{})",
             "  |> Map.put(zero, to_string(zero)) #=> %{0 => \"0\", 1 => \"1\", 2 => \"4\", 3 => \"9\"}"
           ]
  end

  test "inspect with passing expression directly w/o pipe operator" do
    fun = fn ->
      {x, y} = {5, 7}
      Dbg.inspect(x |> max(y), show_vars: true)
    end

    assert dbg_inspect(fun) == [
             "./test/dbg_test.exs:152",
             "  x = 5",
             "  y = 7",
             "  x |> max(y) #=> 7"
           ]
  end
end
