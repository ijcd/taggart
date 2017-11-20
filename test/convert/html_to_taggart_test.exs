defmodule Taggart.Convert.HTMLToTaggartTest do
  use ExUnit.Case
  alias Taggart.Convert.HTMLToTaggart

  @html """
<html>
<body>
  <section id="content" class="foo">
    <p class="headline">Floki</p>
    <span class="headline">Enables search using CSS selectors</span>
    <a href="https://github.com/philss/floki">Github page</a>
    <span data-model="user">philss</span>
  </section>
  <a href="https://hex.pm/packages/floki">Hex package</a>
</body>
</html>
""" |> String.trim

  @taggart """
html do
  body do
    section(id: "content", class: "foo") do
      p(class: "headline") do
	"Floki"
      end
      span(class: "headline") do
	"Enables search using CSS selectors"
      end
      a(href: "https://github.com/philss/floki") do
	"Github page"
      end
      span(data-model: "user") do
	"philss"
      end
    end
    a(href: "https://hex.pm/packages/floki") do
      "Hex package"
    end
  end
end
""" |> String.trim

  @taggart_4sp String.replace(@taggart, "  ", "    ")
  @taggart_tab String.replace(@taggart, "  ", "\t")

  test "converts html to taggart" do
    assert @taggart == HTMLToTaggart.html_to_taggart(@html)
  end

  test "converts html to taggart with 4 space indentation" do
    assert @taggart_4sp == HTMLToTaggart.html_to_taggart(@html, "    ")
  end

  test "converts html to taggart with tab indentation" do
    assert @taggart_tab == HTMLToTaggart.html_to_taggart(@html, "\t")
  end
end
