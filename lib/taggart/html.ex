defmodule Taggart.HTML do
  @moduledoc """
  HTML tags.

  The `use` macro automatically handles any ambiguities between html
  elements and the funcions from `Kernel`. `Kernel.div/2` for example
  is unimported to allow the use of the `div` element. If you still
  need to use `Kernel.div/2`, just call it as `Kernel.div(20, 2)`

  All elements are generated in this module. To use the macros in your
  module:
  ```
  use Taggart.HTML
  ```

  You can exclude some of the tags:
  ```
  use Taggart.HTML, except: [area: 2]
  ```

  If you want more careful control over imports:
  ```
  import Kernel, except: [div: 2]
  import Taggart.HTML
  import Taggart.Tags, only: [taggart: 0, taggart: 1]
  ```
  """

  @external_resource tags_path = Path.join([__DIR__, "html_tags.txt"])
  @external_resource void_tags_path = Path.join([__DIR__, "html_void_tags.txt"])

  @tags (for line <- File.stream!(tags_path, [], :line), do: line |> String.trim |> String.to_atom)
  @void_tags (for line <- File.stream!(void_tags_path, [], :line), do: line |> String.trim |> String.to_atom)

  use Taggart, tags: @tags, void_tags: @void_tags


  defmacro __using__(opts) do
    quote location: :keep do
      import Kernel, except: [div: 2]
      import Taggart.HTML, [unquote_splicing(opts)]
      import Taggart.Tags, only: [taggart: 0, taggart: 1]
    end
  end


  @doc """
  Produces a doctype tag.

  Defaults to html5. Available doctypes are:

   * :html5
   * :html401_strict
   * :html401_transitional
   * :html401_frameset
   * :xhtml10_strict
   * :xhtml10_transitional
   * :xhtml10_frameset
   * :xhtml11

  ## Examples

      iex> html_doctype() |> Phoenix.HTML.safe_to_string()
      "<!DOCTYPE html>"

      iex> html_doctype(:html5) |> Phoenix.HTML.safe_to_string()
      "<!DOCTYPE html>"

      iex> html_doctype(:xhtml11) |> Phoenix.HTML.safe_to_string()
      "<!DOCTYPE html PUBLIC \\"-//W3C//DTD XHTML 1.1//EN\\" \\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\\">"

  """
  defmacro html_doctype(type \\ :html5) do
    quote location: :keep do
      case unquote(type) do
        :html5 -> {:safe, "<!DOCTYPE html>"}
        :html401_strict -> {:safe, ~s|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">|}
        :html401_transitional -> {:safe, ~s|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">|}
        :html401_frameset -> {:safe, ~s|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">|}
        :xhtml10_strict -> {:safe, ~s|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">|}
        :xhtml10_transitional -> {:safe, ~s|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">|}
        :xhtml10_frameset -> {:safe, ~s|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">|}
        :xhtml11 -> {:safe, ~s|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">|}
      end
    end
  end

  @doc """
  Produces an html comment.

  ## Examples

      iex> html_comment("this is a comment") |> Phoenix.HTML.safe_to_string()
      "<!-- this is a comment -->"

  """
  defmacro html_comment(comment) do
    quote location: :keep do
      unquote(comment)
      |> String.replace("-->", "-- >")
      |> (&{:safe, "<!-- #{&1} -->"}).()
    end
  end
end
