defmodule ExExerciseMacro do
  @moduledoc """
  Documentation for `ExExerciseMacro`.
  """

  @doc """
  iex> require ExExerciseMacro
  iex> ExExerciseMacro.ntimes(3, quote do: IO.write("o"))
  [x: 3]
  iex> ExExerciseMacro.ntimes(10, quote do: IO.write("x"))
  [x: 10]
  iex> x = 10
  """
  defmacro ntimes(n, body) do
    quote do
      n = unquote(n)
      ExExerciseMacro.do_loop(:x, 0, (quote do: var!(x) + 1), (quote do: var!(x) >= unquote(n)), unquote(body))
    end
  end

  @doc """
  Equivilent to (do ((x 0 (+ x 1)))
                    ((>= x n))
                    body)

  iex> ExExerciseMacro.do_loop(:x, 0, (quote do: var!(x) + 1), (quote do: var!(x) >= 10), (quote do: var!(x) = var!(x) + 1))
  [x: 10]
  """
  # do_loop x 0 (x + 1) (x >= n) (x = x + 1)
  # var:    Macro.var(var, __MODULE__)
  # init:   0
  # update: (var!(x) + 1)
  # test:   (var!(x) >= var!(n))
  # body:   (var!(x) = var!(x) + 1)
  defmacro do_loop(var, init, update, test, body) when is_atom(var) do
    quote do
      g = fn f, {v, i}, u, t, b ->
        g = [{v, i}]
        case Code.eval_quoted(t, g) do
          {false, g} ->
            g1 = Code.eval_quoted(b, g) |> elem(1)
            g2 = Keyword.update!(g1, v,
              fn _ -> Code.eval_quoted(u, g1) |> elem(0) end)
            l = Keyword.get(g2, v)
            f.(f, {v,l}, u, t, b)
          {true, g} ->
            g
        end
      end
      g.(g, {unquote(var), unquote(init)}, unquote(update), unquote(test), unquote(body))
    end
  end

end
