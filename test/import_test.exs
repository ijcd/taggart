defmodule TaggartImportTest do
  use ExUnit.Case
  import Phoenix.HTML

  use Taggart, tags: [:asdf]

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

defmodule TaggartImportHtmlTest do
  use ExUnit.Case
  import Phoenix.HTML

  import Kernel, except: [div: 2]
  import Taggart.HTML
  import Taggart

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

defmodule TaggartUseTaggartNoDeconflictTest do
  use ExUnit.Case
  import Phoenix.HTML

  import Kernel, except: [div: 2]
  use Taggart, deconflict_imports: false

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

defmodule Taggart.HTMLTest do
  use Taggart, deconflict_imports: false
end

defmodule TaggartUseHTMLNoDeconflictTest do
  use ExUnit.Case
  import Phoenix.HTML

  import Kernel, except: [div: 2]
  use Taggart.HTMLTest

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
