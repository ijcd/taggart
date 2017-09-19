defmodule Taggart.Utils do
  @moduledoc false

  def minspect(ast, label \\ "") do
    str = Macro.to_string(ast)
    #IO.puts("#{label} (ast): #{inspect ast}")
    IO.puts("#{label} (str): #{str}")
    ast
  end
end
