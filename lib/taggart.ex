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

  alias Phoenix.HTML.Tag

  @external_resource tags_path = Path.join([__DIR__, "tags.txt"])

  @tags (for line <- File.stream!(tags_path, [], :line) do
    line |> String.trim |> String.to_atom
  end)

  @doc false
  defmacro __using__(opts) do
    tags = Keyword.get(opts, :tags, @tags)
    ambiguous_imports = __taggart_find_ambiguous_imports(tags)

    quote do
      import Kernel, except: unquote(ambiguous_imports)
      import unquote(__MODULE__)
    end
  end

  defmacro taggart(do: content) do
    content = case content do
      {:__block__, _, inner} -> inner
      _ -> content
    end

    quote bind_quoted: [content: content] do
      content
    end
  end

  for tag <- @tags do    
    defmacro unquote(tag)(content_or_attrs \\ [])

    @doc """
    Make a #{tag} tag.

      ## Examples

          iex> Taggart.#{tag}() |> Phoenix.HTML.safe_to_string()
          "<#{tag}></#{tag}>"

          iex> Taggart.#{tag}("content") |> Phoenix.HTML.safe_to_string()
          "<#{tag}>content</#{tag}>"

          iex> Taggart.#{tag}("content", class: "foo") |> Phoenix.HTML.safe_to_string()
          "<#{tag} class=\\"foo\\">content</#{tag}>"

          iex> Taggart.#{tag}() do end |> Phoenix.HTML.safe_to_string()
          "<#{tag}></#{tag}>"

          iex> Taggart.#{tag}() do "content" end |> Phoenix.HTML.safe_to_string()
          "<#{tag}>content</#{tag}>"

    """
    defmacro unquote(tag)(attrs) when is_list(attrs) do
      tag = unquote(tag)
      {content, attrs} = Keyword.pop(attrs, :do, "")
      content = case content do
        {:__block__, _, inner} -> inner
        _ -> content
      end     

      quote bind_quoted: [tag: tag, content: content, attrs: attrs] do
        Tag.content_tag(tag, content, attrs)
      end
    end

    defmacro unquote(tag)(content) do
      tag = unquote(tag)

      quote bind_quoted: [tag: tag, content: content] do
        Tag.content_tag(tag, content, [])
      end
    end

    defmacro unquote(tag)(content, attrs) when is_list(attrs) do
      tag = unquote(tag)
      content = case content do
        {:__block__, _, inner} -> inner
        _ -> content
      end     

      quote bind_quoted: [tag: tag, content: content, attrs: attrs] do
        Tag.content_tag(tag, content, attrs)
      end
    end
  end
  
  defp __taggart_find_ambiguous_imports(tags) do
    default_imports = Kernel.__info__(:functions) ++ Kernel.__info__(:macros)
    for { name, arity } <- default_imports, arity in 0..2 and name in tags do
      { name, arity }
    end
  end
end