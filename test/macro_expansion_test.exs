defmodule MacroExpansionTest do
  use Taggart.ConnCase
  use Taggart

  test "basic ast" do
    expanded = 
      quote do
        div(class: "foo", id: "bar") do
          "content"
        end
      end

    assert {:div, _, [[class: "foo", id: "bar"], [do: "content"]]} = expanded
  end

  test "desugar div/1 (content)" do
    expanded = 
      quote do
        div("content")
      end
      |> Macro.expand_once(__ENV__)

    assert {:div, _, [[], [do: "content"]]} = expanded
  end

  test "desugar div/1 tag(do: content)" do
    expanded = 
      quote do
        div do
          "content"
        end
      end
      |> Macro.expand_once(__ENV__)

    assert {:div, _, [[], [do: "content"]]} = expanded
  end

  test "desugar div/2, (content, attrs)" do
    expanded = 
      quote do
        div("content", do: "do_arg", id: "bar")
      end
      |> Macro.expand_once(__ENV__)

    assert {:div, _, [[do: "do_arg", id: "bar"], [do: "content"]]} = expanded
  end

  test "desugar div/2, (content, do_arg)" do
    expanded = 
      quote do
        div("content", do: "do_arg")
      end
      |> Macro.expand_once(__ENV__)

    assert {:div, _, [[do: "do_arg"], [do: "content"]]} = expanded
  end
end
