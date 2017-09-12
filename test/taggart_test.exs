defmodule TaggartTest do
  use ExUnit.Case
  doctest Taggart

  test "greets the world" do
    assert Taggart.hello() == :world
  end
end
