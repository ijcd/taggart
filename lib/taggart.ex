defmodule Taggart do
  @moduledoc """
  Markup in Elixir

  All HTML elements are generated in this module.
  To use the element macros outside of components and templates, use `use Taggart`
  instead of `Taggart` to import them in to the current scope. The `use` macro
  automatically handles any ambiguities between html elements and the funcions
  from `Kernel`. `Kernel.div/2` for example is unimported to allow the use of
  the `div` element. If you still need to use `Kernel.div/2`, just call it as
  `Kernel.div(20, 2)`
  """

  import Taggart.Tags, only: [deftag: 1]

  @external_resource tags_path = Path.join([__DIR__, "tags.txt"])

  @tags (for line <- File.stream!(tags_path, [], :line) do
    line |> String.trim |> String.to_atom
  end)

  @doc false
  defmacro __using__(opts) do
    should_deconflict_imports = Keyword.get(opts, :deconflict_imports, true)
    tags = Keyword.get(opts, :tags, @tags)
    ambiguous_imports = find_ambiguous_imports(tags)

    import_ast =
      if should_deconflict_imports do
        quote do
          defmacro __using__(opts) do
            ambiguous_imports = unquote(ambiguous_imports)
            module = __MODULE__
            quote do
              import Kernel, except: unquote(ambiguous_imports)
              import unquote(module)
            end
          end

          import Kernel, except: unquote(ambiguous_imports)
          import Taggart, only: [taggart: 0, taggart: 1]
        end
      else
        quote do
          defmacro __using__(opts) do
            module = __MODULE__
            quote do
              import unquote(module)
              import Taggart, only: [taggart: 0, taggart: 1]
            end
          end

          import Taggart, only: [taggart: 0, taggart: 1]
        end
      end

    tags_ast =
      quote location: :keep, bind_quoted: [
        tags: tags
      ] do
        for tag <- tags do
          deftag unquote(tag)
        end
      end

    quote do
      unquote(import_ast)
      unquote(tags_ast)
    end
  end

  defmacro taggart(), do: {:safe, []}
  defmacro taggart(do: content) do
    content = case content do
      {:__block__, _, inner} -> inner
      _ -> content
    end

    quote location: :keep, bind_quoted: [content: content] do
      content
    end
  end

  defp find_ambiguous_imports(tags) do
    default_imports = Kernel.__info__(:functions) ++ Kernel.__info__(:macros)
    for { name, arity } <- default_imports, arity in 0..2 and name in tags do
      { name, arity }
    end
  end
end
