defmodule Taggart.HTML do
  @moduledoc """
  HTML tags.

  All elements are generated in this module. To use the macros in your
  module:
  ```
  use Taggart.HTML
  ```

  If you want more careful control over imports:
  ```
  import Kernel, except: [div: 2]
  import Taggart.HTML
  import Taggart
  ```
  """

  use Taggart
end
