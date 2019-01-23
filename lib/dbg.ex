defmodule Dbg do
  @moduledoc """
  Dbg module provides an extended version of `IO.inspect/1` function for the debug purposes.
  """

  @doc """
  `Dbg.inspect/2` prints the first argument like regular IO.inspect/1,
  but including filename and line of code,
  where it was called, and a representation of the expression 
  passed as the first argument, provides colored output to simplify it detecting 
  and ability to include values of variables, used it this expression, in this output. 

  It's worth noting that `Dbg.inspect/2` prints its output to :stderr stream. 
  And also doesn't add any performance penalty in `production` enviroment,
  b/c when `Mix.env == :prod` it doesn't change an original AST at all.

  ## Options

  The accepted options are:

    * `show_vars` - if true prints also values of variables which were used in the first argument

  ## Examples

      > x = 7
      > x |> Dbg.inspect()
      
      ./dbg.ex:16
      x # => 7

      > {x, y} = {5, 7}
      > Dbg.inspect(x+y)

      ./dbg.ex:22
      x + y # => 12

  See more examples in tests.
  """
  defmacro inspect(ast, opts \\ [show_vars: false]) do
    inspect(Mix.env(), ast, opts)
  end

  defp inspect(:prod, ast, _opts), do: ast

  defp inspect(_env, ast, opts) do
    value_representation = generate_value_representation(ast)
    vars = get_vars(ast, opts)

    quote do
      result = unquote(ast)

      IO.puts(:stderr, [
        IO.ANSI.red_background(),
        IO.ANSI.bright(),
        "\x1B[K\n",
        Dbg.short_file_name(__ENV__.file),
        ":",
        to_string(__ENV__.line)
      ])

      unquote(vars) |> Dbg.print_vars()

      IO.puts(:stderr, [
        "  ",
        unquote(value_representation),
        " #=> ",
        Kernel.inspect(result),
        "\x1B[K\n",
        IO.ANSI.reset()
      ])

      result
    end
  end

  def print_vars(vars) do
    vars
    |> Enum.each(fn {var_name, var_value} ->
      IO.puts(:stderr, ["  #{var_name} = ", Kernel.inspect(var_value), "\x1B[K"])
    end)
  end

  def short_file_name(file_name) do
    String.replace(file_name, File.cwd!(), ".")
  end

  defp generate_value_representation(ast) do
    ast
    |> Macro.to_string()
    |> Code.format_string!(line_length: 60)
    |> Enum.join()
    |> String.replace("\n", "\n  ")
  end

  defp get_vars(ast, show_vars: true) do
    ast
    |> find_vars([])
    |> Enum.uniq
    |> Enum.map(&{elem(&1, 0), &1})
  end

  defp get_vars(_, _), do: []

  defp find_vars({_, _, [inner_ast]}, vars) do
    find_vars(inner_ast, vars)
  end

  defp find_vars({_, _, [inner_ast | additional_args]}, vars) do
    new_vars = Enum.flat_map(additional_args, &(find_vars(&1, [])))
    find_vars(inner_ast, vars ++ new_vars)
  end

  defp find_vars([var_ast, args], vars) when is_tuple(var_ast) and is_list(args) do
    find_vars([var_ast | args], vars)
  end

  defp find_vars(args, vars) when is_list(args) do
    new_vars = args |> Enum.map(&only_vars/1) |> Enum.filter(& &1)
    vars ++ new_vars
  end

  defp find_vars({var_name, _, nil} = var_ast, vars) when is_atom(var_name) do
    [var_ast | vars]
  end

  defp find_vars(_, vars), do: vars

  defp only_vars({var_name, _, nil} = var_ast) when is_atom(var_name), do: var_ast
  defp only_vars([{label, var_ast}]) when is_atom(label), do: only_vars(var_ast)
  defp only_vars({label, var_ast}) when is_atom(label), do: only_vars(var_ast)
  defp only_vars(_), do: false
end
