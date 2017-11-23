defmodule Taggart do
  @moduledoc """
  Generates tags upon use.

  The `use` macro automatically handles any ambiguities between html
  elements and the funcions from `Kernel`. `Kernel.div/2` for example
  is unimported to allow the use of the `div` element. If you still
  need to use `Kernel.div/2`, just call it as `Kernel.div(20, 2)`

  ### Importing

  Generates all known HTML tags as macros upon import:
  ```
  use Taggart

  div do
    span("some content")
  end
  ```

  Generates just the given tags:
  ```
  use Taggart, tags: [:foo, :bar]

  foo do
    bar("some content")
  end
  ```

  If you would like to carefully control the imports:
  ```
  import Kernel, except: [div: 2]
  use Taggart, deconflict_imports: false, except: [section: 2]
  ```

  """

  import Taggart.Tags, only: [deftag: 1, deftag: 2]

  @external_resource tags_path = Path.join([__DIR__, "tags.txt"])
  @external_resource void_tags_path = Path.join([__DIR__, "tags_void.txt"])

  @tags (for line <- File.stream!(tags_path, [], :line), do: line |> String.trim |> String.to_atom)
  @void_tags (for line <- File.stream!(void_tags_path, [], :line), do: line |> String.trim |> String.to_atom)

  defmacro __using__(opts) do
    deconflict_imports = Keyword.get(opts, :deconflict_imports, true)

    tags = Keyword.get(opts, :tags, @tags)
    void_tags = Keyword.get(opts, :void_tags, @void_tags)

    exclude_imports =
      if deconflict_imports do
        find_ambiguous_imports(tags)
      else
        []
      end

    import_ast =
      quote location: :keep do
        defmacro __using__(opts) do
          module = __MODULE__
	  taggart_excepts = Keyword.get(opts, :except, [])
	  deconflict_imports = Keyword.get(opts, :deconflict_imports, true)

	  exclude_imports =
	    if deconflict_imports do
	      unquote(exclude_imports)
	    else
	      []
	    end

          quote location: :keep do
            import Kernel, except: unquote(exclude_imports)
            import Taggart, only: [
              taggart: 0, taggart: 1,
              html_doctype: 0, html_doctype: 1,
              html_comment: 1
            ]
	    import unquote(module), except: unquote(taggart_excepts)
          end
        end

        import Kernel, except: unquote(exclude_imports)
        import Taggart, only: [
          taggart: 0, taggart: 1,
          html_doctype: 0, html_doctype: 1,
          html_comment: 1
        ]
      end

    tags_ast =
      quote location: :keep, bind_quoted: [
        tags: tags,
        void_tags: void_tags
      ] do
        for tag <- tags do
          deftag(unquote(tag))
        end
        for tag <- void_tags do
          deftag(unquote(tag), void: true)
        end
      end

    quote location: :keep do
      unquote(import_ast)
      unquote(tags_ast)
    end
  end

  @doc "See `taggart/1`"
  defmacro taggart() do
    quote do
      {:safe, ""}
    end
  end

  @doc """
  Allows grouping tags in a block.

  Groups tags such that they all become part of the result. Normally,
  with an Elixir block, only the last expression is part of the value.
  This is useful, for example, as the do block of
  `Phoenix.HTML.Form.form_for/4`.

  ```
  form_for(conn, "/users", [as: :user], fn f ->
    taggart do
      label do
        "Name:"
        text_input(f, :name)
      end
      label do
        "Age:"
        select(f, :age, 18..100)
      end
    end
  end
  ```

  ## Examples

      iex> taggart() |> Phoenix.HTML.safe_to_string()
      ""

      iex> (taggart do div() ; span() end) |> Phoenix.HTML.safe_to_string()
      "<div></div><span></span>"

  """
  defmacro taggart(do: content) do
    content = case content do
      {:__block__, _, inner} -> inner
      _ -> content
    end

    quote location: :keep do
      content = unquote(content)
      case content do
        # monadically combine array of [{:safe, content}, ...] -> {:safe, [content, ...]}
        clist when is_list(clist) ->
          inners =
            for c <- clist do
              {:safe, inner} = c
              inner
            end
          {:safe, [inners]}

        {:safe, _} = c -> c

        c -> Phoenix.HTML.html_escape(c)
      end
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
    quote do
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
    quote do
      unquote(comment)
      |> String.replace("-->", "-- >")
      |> (&{:safe, "<!-- #{&1} -->"}).()
    end
  end

  defp find_ambiguous_imports(tags) do
    default_imports = Kernel.__info__(:functions) ++ Kernel.__info__(:macros)
    for { name, arity } <- default_imports, arity in 0..2 and name in tags do
      { name, arity }
    end
  end
end
