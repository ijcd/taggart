defmodule Taggart do
  @moduledoc """
  Generates tags upon use.

  ### Importing

  Generates all known HTML tags as macros upon import:
  ```
  use Taggart.HTML

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

  """


  defmacro __using__(opts) do
    tags = Keyword.get(opts, :tags, [])
    void_tags = Keyword.get(opts, :void_tags, [])

    quote location: :keep, bind_quoted: [
      tags: tags,
      void_tags: void_tags
    ] do

      import Taggart.Tags, only: [deftag: 1, deftag: 2]#, taggart: 0, taggart: 1]

      # define normal tags
      for tag <- tags do
        deftag(unquote(tag))
      end

      # define void tags
      for tag <- void_tags do
        deftag(unquote(tag), void: true)
      end
    end
  end
end
