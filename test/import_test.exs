defmodule TaggartUseTest do
  use ExUnit.Case
  import Phoenix.HTML

  use Taggart, tags: [:asdf]
  import Taggart.Tags, only: [taggart: 0, taggart: 1]

  test "asdf should be avialable" do
    assert "<asdf></asdf>" == asdf() |> safe_to_string()
  end

  test "taggart/0 should be avialable" do
    assert "" == (taggart()) |> safe_to_string
  end

  test "taggart/1 should be avialable" do
    assert "<asdf></asdf>" == (taggart do asdf() end) |> safe_to_string
  end
end

defmodule TaggartUseHTMLTest do
  use ExUnit.Case
  import Phoenix.HTML

  use Taggart.HTML

  test "div/2 should be avialable" do
    assert "<div class=\"foo\">content</div>" == div("content", class: "foo") |> safe_to_string
  end

  test "taggart/0 should be avialable" do
    assert "" == (taggart()) |> safe_to_string
  end

  test "taggart/1 should be avialable" do
    assert "<div></div>" == (taggart do div() end) |> safe_to_string
  end
end

defmodule TaggartImportHtmlTest do
  use ExUnit.Case
  import Phoenix.HTML

  import Kernel, except: [div: 2]
  import Taggart.HTML
  import Taggart.Tags, only: [taggart: 0, taggart: 1]

  test "div/2 should be avialable" do
    assert "<div class=\"foo\">content</div>" == div("content", class: "foo") |> safe_to_string
  end

  test "taggart/0 should be avialable" do
    assert "" == (taggart()) |> safe_to_string
  end

  test "taggart/1 should be avialable" do
    assert "<div></div>" == (taggart do div() end) |> safe_to_string
  end
end

defmodule TaggartImportHtmlWithoutDivTest do
  use ExUnit.Case
  import Phoenix.HTML

  import Taggart.HTML, except: [div: 2]
  import Taggart.Tags, only: [taggart: 0, taggart: 1]

  test "Kernel.div/2 should be avialable" do
    assert 3 == div(10, 3)
  end

  test "taggart/0 should be avialable" do
    assert "" == (taggart()) |> safe_to_string
  end

  test "taggart/1 should be avialable" do
    assert "<section></section>" == (taggart do section() end) |> safe_to_string
  end
end
