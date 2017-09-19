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
    deconflict_imports = Keyword.get(opts, :deconflict_imports, true)
    tags = Keyword.get(opts, :tags, @tags)
    exclude_imports =
      if deconflict_imports do
        find_ambiguous_imports(tags)
      else
        []
      end

    import_ast =
      quote do
        defmacro __using__(opts) do
          module = __MODULE__

          exclude_imports = unquote(exclude_imports)
          quote do
            import Kernel, except: unquote(exclude_imports)
            import Taggart, only: [taggart: 0, taggart: 1]
            import unquote(module)
          end
        end

        import Kernel, except: unquote(exclude_imports)
        import Taggart, only: [taggart: 0, taggart: 1]
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

  @doc """
  Wrap tags in a NOOP. Useful for the do block of Phoenix's
  form_for(), as only the last value of the passed-in-function is
  returned as form content.

  ```
    form_for(conn, "/users", [as: :user], fn f ->
      taggart do
        label do
          "Name:"
          text_input(f, :name)
        end
        label do
          "Age:"
          select(f, :age, 18..100)
        end
      end
    end
  ```

    ## Examples

        iex> taggart() |> Phoenix.HTML.safe_to_string()
        ""

        iex> (taggart do div() ; span() end) |> Phoenix.HTML.safe_to_string()
        "<div></div><span></span>"

  """
  defmacro taggart(), do: {:safe, []}
  defmacro taggart(do: content) do
    content = case content do
      {:__block__, _, inner} -> inner
      _ -> content
    end

    quote do
      content = unquote(content)
      case content do
        {:safe, _} = c -> c

        # monadically combine array of [{:safe, content}, ...] -> {:safe, [content, ...]}
        clist when is_list(clist) ->
          inners =
            for c <- clist do
              {:safe, inner} = c
              inner
            end
          {:safe, [inners]}
      end
    end
  end

  defp find_ambiguous_imports(tags) do
    default_imports = Kernel.__info__(:functions) ++ Kernel.__info__(:macros)
    for { name, arity } <- default_imports, arity in 0..2 and name in tags do
      { name, arity }
    end
  end
end
