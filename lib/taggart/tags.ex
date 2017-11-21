defmodule Taggart.Tags do
  @moduledoc """
  Define HTML tags.

  Contains macros for creating a tag-based DSL.
  """

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

        Taggart.Tags.normalized_call(tag, attrs, content)
      end

      defmacro unquote(tag)(content) do
        tag = unquote(tag)  # push tag down to next quote
        attrs = Macro.escape([])

        Taggart.Tags.normalized_call(tag, attrs, content)
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

        Taggart.Tags.normalized_call(tag, attrs, content)
      end

      defmacro unquote(tag)(attrs, do: content) do
        tag = unquote(tag)
        content =
          case content do
            {:__block__, _, inner} -> inner
            _ -> content
          end

        quote do
          Phoenix.HTML.Tag.content_tag(unquote(tag), unquote(content), unquote(attrs))
        end
      end

      defmacro unquote(tag)(content, attrs) when is_list(attrs) do
        tag = unquote(tag)

        Taggart.Tags.normalized_call(tag, attrs, content)
      end
    end
  end

  @doc """
  Define a new void tag.

  ```
  deftag :hr, void: true
  deftag :img, void: true

  hr()
  img(class: "red")
  ```
  """
  defmacro deftag(tag, void: true) do
    quote location: :keep, bind_quoted: [
      tag: Macro.escape(tag, unquote: true)
    ] do
      @doc """
      Produce a void "#{tag}" tag.

      ## Examples

          iex> #{tag}() |> Phoenix.HTML.safe_to_string()
          "<#{tag}>"

          iex> #{tag}(class: "foo") |> Phoenix.HTML.safe_to_string()
          "<#{tag} class=\\"foo\\">"
      """
      defmacro unquote(tag)(attrs \\ []) do
        tag = unquote(tag)

        quote do
          Phoenix.HTML.Tag.tag(unquote(tag), unquote(attrs))
        end
      end
    end
  end

  def normalized_call(tag, attrs, content) do
    quote do
      unquote(tag)(unquote(attrs)) do
        unquote(content)
      end
    end
  end
end
