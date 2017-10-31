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

	Taggart.Tags.content_tag(tag, attrs, content)
      end

      defmacro unquote(tag)(content, attrs) when is_list(attrs) do
        tag = unquote(tag)

        Taggart.Tags.normalized_call(tag, attrs, content)
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

  def content_tag(tag, attrs, content) do
    quote do
      content = unquote(content)
      {:safe, escaped} = Phoenix.HTML.html_escape(content)

      name = to_string(unquote(tag))
      attrs = unquote(attrs)
      {:safe, [?<, name, Taggart.Tags.build_attrs(name, attrs), ?>, escaped, ?<, ?/, name, ?>]}
    end
  end

  @tag_prefixes [:aria, :data]

  def build_attrs(_tag, []), do: []
  def build_attrs(tag, attrs), do: build_attrs(tag, attrs, [])

  def build_attrs(_tag, [], acc),
    do: acc |> Enum.sort |> tag_attrs
  def build_attrs(tag, [{k, v}|t], acc) when k in @tag_prefixes and is_list(v) do
    build_attrs(tag, t, nested_attrs(dasherize(k), v, acc))
  end
  def build_attrs(tag, [{k, true}|t], acc) do
    build_attrs(tag, t, [{dasherize(k)}|acc])
  end
  def build_attrs(tag, [{_, false}|t], acc) do
    build_attrs(tag, t, acc)
  end
  def build_attrs(tag, [{_, nil}|t], acc) do
    build_attrs(tag, t, acc)
  end
  def build_attrs(tag, [{k, v}|t], acc) do
    build_attrs(tag, t, [{dasherize(k), v}|acc])
  end

  defp dasherize(value) when is_atom(value),   do: dasherize(Atom.to_string(value))
  defp dasherize(value) when is_binary(value), do: String.replace(value, "_", "-")

  defp tag_attrs([]), do: []
  defp tag_attrs(attrs) do
    for a <- attrs do
      case a do
        {k, v} -> [?\s, k, ?=, ?", attr_escape(v), ?"]
        {k} -> [?\s, k]
      end
    end
  end

  defp attr_escape({:safe, data}),
    do: data
  defp attr_escape(nil),
    do: []
  defp attr_escape(other) when is_binary(other),
    do: Plug.HTML.html_escape(other)
  defp attr_escape(other),
    do: Phoenix.HTML.Safe.to_iodata(other)

  defp nested_attrs(attr, dict, acc) do
    Enum.reduce dict, acc, fn {k,v}, acc ->
      attr_name = "#{attr}-#{dasherize(k)}"
      case is_list(v) do
	    true  -> nested_attrs(attr_name, v, acc)
	    false -> [{attr_name, v}|acc]
      end
    end
  end
end
