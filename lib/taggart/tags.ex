defmodule Taggart.Tags do
  alias Phoenix.HTML.Tag

  defmacro deftag(tag) do
    quote location: :keep, bind_quoted: [
      tag: Macro.escape(tag, unquote: true)
    ] do

      defmacro unquote(tag)(content_or_attrs \\ [])

      @doc """
      Make a #{tag} tag.

        ## Examples

            iex> #{tag}() |> Phoenix.HTML.safe_to_string()
            "<#{tag}></#{tag}>"

            iex> #{tag}("content") |> Phoenix.HTML.safe_to_string()
            "<#{tag}>content</#{tag}>"

            iex> #{tag}("content", class: "foo") |> Phoenix.HTML.safe_to_string()
            "<#{tag} class=\\"foo\\">content</#{tag}>"

            iex> #{tag}() do end |> Phoenix.HTML.safe_to_string()
            "<#{tag}></#{tag}>"

            iex> #{tag}() do "content" end |> Phoenix.HTML.safe_to_string()
            "<#{tag}>content</#{tag}>"

      """
      defmacro unquote(tag)(attrs) when is_list(attrs) do
        tag = unquote(tag)  # push tag down to next quote
        {content, attrs} = Keyword.pop(attrs, :do, "")
        content = case content do
          {:__block__, _, inner} -> inner
          _ -> content
        end

        quote do
          Tag.content_tag(unquote(tag), unquote(content), unquote(attrs))
        end
      end

      defmacro unquote(tag)(content) do
        tag = unquote(tag)  # push tag down to next quote
        quote do
          Tag.content_tag(unquote(tag), unquote(content), [])
        end
      end

      defmacro unquote(tag)(content, attrs) when is_list(attrs) do
        tag = unquote(tag)
        content = case content do
                    {:__block__, _, inner} -> inner
                    _ -> content
                  end

        quote do
          Tag.content_tag(unquote(tag), unquote(content), unquote(attrs))
        end
      end

    end
  end
end
