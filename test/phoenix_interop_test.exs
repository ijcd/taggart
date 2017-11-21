defmodule PhoenixInteropTest do
  import Phoenix.HTML

  use Taggart.ConnCase
  use Taggart

  test "inside a phoenix form", %{conn: conn} do
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
end
