defmodule Taggart.Tags do
  @moduledoc """
  Define HTML tags.

  Contains macros for creating a tag-based DSL.
  """

  alias Phoenix.HTML.Tag


  @doc """
  Define a new tag.

  ```
  deftag :span
  deftag :div

  div do
    span("Foo")
  end
  ```
  """
  defmacro deftag(tag) do
    quote location: :keep, bind_quoted: [
      tag: Macro.escape(tag, unquote: true)
    ] do

      defmacro unquote(tag)(content_or_attrs \\ [])

      defmacro unquote(tag)(attrs)
        when is_list(attrs)
      do
        tag = unquote(tag)  # push tag down to next quote
        {content, attrs} = Keyword.pop(attrs, :do, "")

        quote do
          unquote(tag)(unquote(attrs)) do
            unquote(content)
          end
        end
      end

      defmacro unquote(tag)(content) do
        tag = unquote(tag)  # push tag down to next quote
        attrs = Macro.escape([])

        quote do
          unquote(tag)(unquote(attrs)) do
            unquote(content)
          end
        end
      end

      @doc """
      Produce a "#{tag}" tag.

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
      defmacro unquote(tag)(content, attrs)
        when not is_list(content)
      do
        tag = unquote(tag)

        quote do
          unquote(tag)(unquote(attrs)) do
            unquote(content)
          end
        end
      end

      defmacro unquote(tag)(attrs, do: content) do
        tag = unquote(tag)
        content =
          case content do
            {:__block__, _, inner} -> inner
            _ -> content
          end

        quote do
          Tag.content_tag(unquote(tag), unquote(content), unquote(attrs))
        end
      end

      defmacro unquote(tag)(content, attrs) when is_list(attrs) do
        tag = unquote(tag)

        quote do
          unquote(tag)(unquote(attrs)) do
            unquote(content)
          end
        end
      end
    end
  end
end
