defmodule TaggartImportTest do
  use ExUnit.Case
  import Phoenix.HTML

  use Taggart, tags: [:div]

  test "div should be avialable" do
    assert "<div></div>" == div() |> safe_to_string()
  end

  test "span should not be avialable" do
    assert "<span></span>" == span() |> safe_to_string()
  end
end
