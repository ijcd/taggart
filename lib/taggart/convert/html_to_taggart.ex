defmodule Taggart.Convert.HTMLToTaggart do
  use Taggart.HTML
  alias Inspect.Algebra, as: IA

  @spec html_to_taggart(String.t, String.t, non_neg_integer()) :: String.t
  def html_to_taggart(html, indent \\ "  ", width \\ 1000) do
    html
    |> Floki.parse()
    |> to_taggart(1)
    |> IA.format(width)
    |> Enum.join
    |> adjust_indent(indent)
  end

  defp to_taggart({tag, attrs, body}, indent) do
    call =
      case attrs do
	[] -> tag
	_ -> IA.surround("#{tag}(", attrs_doc(attrs), ")")
      end

    case body do
      [] ->
	call
      _ ->
	IA.nest((
	  IA.glue(call, "do")
	  |> IA.line(to_taggart(body, indent))
	), indent)
	|> IA.line("end")
    end
  end

  defp to_taggart([content], _indent) when is_binary(content) do
    ~s|"#{content}"|
  end

  defp to_taggart(tags, indent) when is_list(tags) do
    tags
    |> Enum.map(fn t -> to_taggart(t, indent) end)
    |> IA.fold_doc(fn(doc, acc) -> IA.line(doc, acc) end)
  end

  defp to_taggart({:comment, comment}, _indent) do
    "html_comment(#{inspect comment})"
  end

  defp to_taggart(text, _indent) when is_bitstring(text) do
    inspect(text)
  end

  defp attrs_doc([]), do: IA.empty()
  defp attrs_doc(attrs) do
    attrs
    |> Enum.map(&attr_doc/1)
    |> IA.fold_doc(fn(doc, acc) -> IA.glue(doc, ", ", acc) end)
  end

  defp attr_doc({attr, value}) do
    a = "#{attr}" |> String.to_atom |> Atom.to_string
    IA.glue(a, ": ", inspect(value))
  end

  defp adjust_indent(str, indent) do
    str
    |> String.split("\n")
    |> Enum.map(fn s ->
      String.replace_leading(s, " ", indent)
    end)
    |> Enum.join("\n")
  end
end
