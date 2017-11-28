# We can't detect an empty stdin since erlang doesn't have an isatty() that
# we can reach. Optionally, we could wrap in a bash script and use something
# like this:
#
# if [ -t 0 ] ; then
#     # this shell has a std-input, so we're not in batch mode
#    .....
#  else
#     # we're in batch mode
#
#     ....
#  fi

defmodule Taggart.CLI do
  alias Taggart.Convert.HTMLToTaggart

  @moduledoc """
  Command line interface for Taggart
  """

  def main(args) do
    args
    |> parse_args
    |> run
  end

  defp parse_args(args) do
    {flags, _args, _other} = OptionParser.parse(args, switches: [indent: :string, help: :boolean], aliases: [h: :help])

    # set defaults
    flags = Keyword.put_new(flags, :indent, "2")

    cond do
      Keyword.has_key?(flags, :help) -> :help
      true -> {:start, flags}
    end
  end

  defp run(:help) do
    Bunt.puts [:steelblue, """
    taggart [--indent <n|tabs>] [--help]

      --help    Show this message.
      --indent  Either n (number of spaces to indent) or "tabs"
    """]
  end

  defp run({:start, flags}) do
    indent =
      case Keyword.get(flags, :indent) do
	      "tabs" ->
	        "\t"
	      n ->
	        try do
	          n = String.to_integer(n)
	          String.duplicate(" ", n)
	        rescue
	          ArgumentError -> raise "n must be an integer or \"tabs\" (see taggart --help)"
	        end
      end

    IO.read(:all)
    |> HTMLToTaggart.html_to_taggart(indent)
    |> IO.puts
  end
end
