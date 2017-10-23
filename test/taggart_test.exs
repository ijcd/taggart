defmodule TaggartTest do
  import Phoenix.HTML

  use Taggart.ConnCase
  use Taggart

#   doctest Taggart

  test "simple html" do
    assert "<div></div>" == div() |> safe_to_string()
    assert "<span></span>" == span() |> safe_to_string()
  end

  test "with content" do
    assert "<div>content</div>" == div("content") |> safe_to_string
    assert "<span>content</span>" == span("content") |> safe_to_string
  end

  test "with attributes" do
    assert "<div class=\"attr\"></div>" == div(class: "attr") |> safe_to_string
    assert "<span class=\"attr\"></span>" == span(class: "attr") |> safe_to_string

    assert "<div class=\"attr\" id=\"bar\"></div>" == div(class: "attr", id: "bar") |> safe_to_string
    assert "<span class=\"attr\" id=\"bar\"></span>" == span(class: "attr", id: "bar") |> safe_to_string
  end

  test "with content as an arg, and attrs" do
    assert "<div class=\"foo\">content</div>" == div("content", class: "foo") |> safe_to_string
    assert "<span class=\"foo\">content</span>" == span("content", class: "foo") |> safe_to_string

    assert "<div class=\"foo\" id=\"bar\">content</div>" == div("content", class: "foo", id: "bar") |> safe_to_string
    assert "<span class=\"foo\" id=\"bar\">content</span>" == span("content", class: "foo", id: "bar") |> safe_to_string
  end

  test "with content as an arg, and do attrs" do
    assert "<div do=\"do_arg\">content</div>" == div("content", do: "do_arg") |> safe_to_string
    assert "<span do=\"do_arg\">content</span>" == span("content", do: "do_arg") |> safe_to_string

    assert "<div do=\"do_arg\" id=\"bar\">content</div>" == div("content", do: "do_arg", id: "bar") |> safe_to_string
    assert "<span do=\"do_arg\" id=\"bar\">content</span>" == span("content", do: "do_arg", id: "bar") |> safe_to_string
  end

  test "with do: nil" do
    assert "<div></div>" == (div do: nil) |> safe_to_string()
    assert "<span></span>" == (span do: nil) |> safe_to_string()
  end

  test "with empty do block" do
    assert "<div></div>" == (div do end) |> safe_to_string
    assert "<span></span>" == (span do end) |> safe_to_string
  end

  test "with do block with content" do
    assert "<div>content</div>" == (div do "content" end) |> safe_to_string
    assert "<span>content</span>" == (span do "content" end) |> safe_to_string
  end

  test "with do block with content and attrs" do
    assert "<div class=\"foo\">content</div>" == (div(class: "foo") do "content" end) |> safe_to_string
    assert "<span class=\"foo\">content</span>" == (span(class: "foo") do "content" end) |> safe_to_string

    assert "<div class=\"foo\" id=\"bar\">content</div>" == (div(class: "foo", id: "bar") do "content" end) |> safe_to_string
    assert "<span class=\"foo\" id=\"bar\">content</span>" == (span(class: "foo", id: "bar") do "content" end) |> safe_to_string
  end

  test "with do block with empty content and attrs with do" do
    assert "<div do=\"do_attr\"></div>" == (div(do: "do_attr") do end) |> safe_to_string
    assert "<span do=\"do_attr\"></span>" == (span(do: "do_attr") do end) |> safe_to_string

    assert "<div do=\"do_attr\" id=\"bar\"></div>" == (div(do: "do_attr", id: "bar") do end) |> safe_to_string
    assert "<span do=\"do_attr\" id=\"bar\"></span>" == (span(do: "do_attr", id: "bar") do end) |> safe_to_string
  end

  test "with do block with content and attrs with do" do
    assert "<div do=\"do_attr\">content</div>" == (div(do: "do_attr") do "content" end) |> safe_to_string
    assert "<span do=\"do_attr\">content</span>" == (span(do: "do_attr") do "content" end) |> safe_to_string

    assert "<div do=\"do_attr\" id=\"bar\">content</div>" == (div(do: "do_attr", id: "bar") do "content" end) |> safe_to_string
    assert "<span do=\"do_attr\" id=\"bar\">content</span>" == (span(do: "do_attr", id: "bar") do "content" end) |> safe_to_string
  end

  test "with nested calls" do
    assert "<div><div></div></div>" == div(div()) |> safe_to_string
    assert "<span><span></span></span>" == span(span()) |> safe_to_string
  end

  test "with nested do blocks" do
    assert "<div><div></div></div>" == (div do div do end end) |> safe_to_string
    assert "<span><span></span></span>" == (span do span do end end) |> safe_to_string
  end

  test "with more deeply nested do blocks" do
    assert "<div><div><div></div></div></div>" == (div do div do div do end end end) |> safe_to_string
    assert "<span><span><span></span></span></span>" == (span do span do span do end end end) |> safe_to_string
    assert "<div><span><div><span></span></div></span></div>" == (div do span do div do span do end end end end) |> safe_to_string
  end

  test "with siblings blocks" do
    assert "<div><div></div><div></div></div>" == (div do div do end ; div do end end) |> safe_to_string
    assert "<span><span></span><span></span></span>" == (span do span do end ; span do end end) |> safe_to_string
    assert "<div><span></span><div></div></div>" == (div do span do end ; div do end end) |> safe_to_string
  end

  test "with nested calls with attrs" do
    assert "<div class=\"foo\"><div class=\"bar\"></div></div>" == div(div(class: "bar"), class: "foo") |> safe_to_string
    assert "<span class=\"foo\"><span class=\"bar\"></span></span>" == span(span(class: "bar"), class: "foo") |> safe_to_string
  end

  test "with nested do blocks with attrs" do
    assert "<div class=\"foo\"><div class=\"bar\"></div></div>" == (div(class: "foo") do div(class: "bar") end) |> safe_to_string
    assert "<span class=\"foo\"><span class=\"bar\"></span></span>" == (span(class: "foo") do span(class: "bar") end) |> safe_to_string
  end

  test "with more deeply nested do blocks with attrs" do
    assert "<div class=\"foo\"><div class=\"bar\"><div class=\"baz\"></div></div></div>" == (div(class: "foo") do div(class: "bar") do div(class: "baz") do end end end) |> safe_to_string
    assert "<span class=\"foo\"><span class=\"bar\"><span class=\"baz\"></span></span></span>" == (span(class: "foo") do span(class: "bar") do span(class: "baz") do end end end) |> safe_to_string
    assert "<div class=\"foo\"><span class=\"bar\"><div class=\"baz\"><span class=\"bang\"></span></div></span></div>" == (div(class: "foo") do span(class: "bar") do div(class: "baz") do span(class: "bang") do end end end end) |> safe_to_string
  end

  test "with siblings blocks with attrs" do
    assert "<div class=\"foo\"><div class=\"bar\"></div><div class=\"baz\"></div></div>" == (div(class: "foo") do div(class: "bar") do end ; div(class: "baz") do end end) |> safe_to_string
    assert "<span class=\"foo\"><span class=\"bar\"></span><span class=\"baz\"></span></span>" == (span(class: "foo") do span(class: "bar") do end ; span(class: "baz") do end end) |> safe_to_string
    assert "<div class=\"foo\"><span class=\"bar\"></span><div class=\"baz\"></div></div>" == (div(class: "foo") do span(class: "bar") do end ; div(class: "baz") do end end) |> safe_to_string
  end

  test "non-string content" do
    assert "<span>5</span>" == span(5) |> safe_to_string
    assert "<span>foo</span>" == span(:foo) |> safe_to_string
    assert "<span>5</span>" == span(do: 5) |> safe_to_string
    assert "<span>foo</span>" == span(do: :foo) |> safe_to_string
    assert "<span>5</span>" == (span() do 5 end) |> safe_to_string
    assert "<span>foo</span>" == (span() do :foo end) |> safe_to_string
  end

  test "empty taggart" do
    assert "" == taggart() |> safe_to_string
  end

  test "taggart with content" do
    assert "<div></div>" == (taggart do div() end) |> safe_to_string
  end

  test "taggart with string content" do
    a = ""
    assert a == (taggart do ; end) |> safe_to_string
  end

  test "taggart with sibling content" do
    assert "<div></div><span></span>" == (taggart do div() ; span() end) |> safe_to_string
  end

  test "normal html" do
    name = "Vincent"

    html = html do
      body do
        div do
          h3 "Person"
          p name, class: "name"
          p 2 * 19, class: "age"
        end
      end
    end
    |> safe_to_string

    assert "<html><body><div><h3>Person</h3><p class=\"name\">Vincent</p><p class=\"age\">38</p></div></body></html>" == html
  end

  test "works with functions and looping" do
    times = [1, 2, 3, 4]

    my_label = fn (i) -> label(i) end

    h =
      html do
        for x <- times, do: my_label.(x)
      end
      |> safe_to_string

    assert "<html><label>1</label><label>2</label><label>3</label><label>4</label></html>" = h
  end

  test "inside a phoenix form", %{conn: conn} do
    alias Phoenix.HTML
    alias Phoenix.HTML.Form

    form = Form.form_for(conn, "/users", [as: :user], fn f ->
      taggart do
        label do
          "Name:"
          Form.text_input(f, :name)
        end
        label do
          "Age:"
          Form.select(f, :age, 18..100)
        end
        Form.submit("Submit")
      end
    end)
    |> safe_to_string

    assert "<form accept-charset=\"UTF-8\" action=\"/users\" method=\"post\"><input name=\"_csrf_token\" type=\"hidden\"" <> _ = form
    assert String.contains?(form, "Name:")
    assert String.contains?(form, "Age:")
    assert String.ends_with?(form, "<button type=\"submit\">Submit</button></form>")
  end

  test "with an embedded phoenix form" do
    alias Phoenix.HTML
    alias Phoenix.HTML.Form

    name = "Vincent"

    h =
      html do
        body do
          div do
            h3 "Person"
            p name, class: "name"
            p 2 * 19, class: "age"
            Form.form_for(build_conn(), "/users", [as: :user], fn f ->
              taggart do
                label do
                  "Name:"
                  Form.text_input(f, :name)
                end
                label do
                  "Age:"
                  Form.select(f, :age, 18..100)
                end
                Form.submit("Submit")
              end
            end)
          end
        end
      end
      |> safe_to_string

    assert "<html><body><div><h3>Person</h3><p class=\"name\">Vincent</p><p class=\"age\">38</p><form accept-charset=\"UTF-8\" action=\"/users\" method=\"post\">" <> _ = h
    assert String.contains?(h, "<p class=\"name\">Vincent</p>")
    assert String.contains?(h, "Name:")
    assert String.contains?(h, "Age:")
    assert String.ends_with?(h, "<button type=\"submit\">Submit</button></form></div></body></html>")
  end

  test "doctypes" do
    assert "<!DOCTYPE html>" == html_doctype() |> safe_to_string
    assert "<!DOCTYPE html>" == html_doctype(:html5) |> safe_to_string    
    assert ~s|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">| == html_doctype(:html401_strict) |> safe_to_string
    assert ~s|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">| == html_doctype(:html401_transitional) |> safe_to_string
    assert ~s|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">| == html_doctype(:html401_frameset) |> safe_to_string
    assert ~s|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">| == html_doctype(:xhtml10_strict) |> safe_to_string
    assert ~s|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">| == html_doctype(:xhtml10_transitional) |> safe_to_string
    assert ~s|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">| == html_doctype(:xhtml10_frameset) |> safe_to_string
    assert ~s|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">| == html_doctype(:xhtml11) |> safe_to_string
  end

  test "an html comment" do
    assert "<!-- this is a string comment -->" == html_comment("this is a string comment") |> safe_to_string
  end

  test "an multiline html comment" do
    comment = """
this is
a
multiline
comment
"""
    assert "<!-- this is\na\nmultiline\ncomment\n -->" == html_comment(comment) |> safe_to_string    
  end

  test "an html with escaping" do
    assert "<!-- this is a -- > string comment -->" == html_comment("this is a --> string comment") |> safe_to_string
  end
end
