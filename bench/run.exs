Application.ensure_started(:phoenix)

defmodule TaggartMarkup do
  use Taggart

  def simple_list(items) do
    ul do
      for i <- items, do: li(i)
    end
  end

  def title_list(title: title, items: items) do
    taggart do
      h3(title)
      simple_list(items)
    end
  end

  def with_lists() do
    html do
      head do
        meta charset: "utf-8"
        meta "http-equiv": "X-UA-Compatible", content: "IE=edge"
        meta name: "viewport", content: "width=device-width, initial-scale=1"
        meta name: "description", content: "result type benchmarking"
        meta name: "author", content: "zambal"
      end
      body do
        h2 String.capitalize("lists")
        ul do
          li 1 + 1
          li 2 + 2
          li 3 + 3
          li 4 + 4
        end
        ul do
          li 1 + 1
          li 2 + 2
          li 3 + 3
          li 4 + 4
        end
        ul do
          li 1 + 1
          li 2 + 2
          li 3 + 3
          li 4 + 4
        end
        ul do
          li 1 + 1
          li 2 + 2
          li 3 + 3
          li 4 + 4
        end
      end
    end
  end

  def with_simple_lists() do
    html do
      head do
        meta charset: "utf-8"
        meta "http-equiv": "X-UA-Compatible", content: "IE=edge"
        meta name: "viewport", content: "width=device-width, initial-scale=1"
        meta name: "description", content: "result type benchmarking"
        meta name: "author", content: "zambal"
      end
      body do
        h2 String.capitalize("lists")
        simple_list [
          "Strawberry",
          "Banana",
          "Apple",
          "Orange",
        ]
        simple_list [
          "C",
          "Java",
          "Erlang",
          "Elixir",
          "Javascript",
        ]
        simple_list [
          "Netherlands",
          "Germany",
          "Denmark",
          "Poland",
        ]
        simple_list [
          "Mercury",
          "Venus",
          "Earth",
          "Mars",
        ]
      end
    end
  end
  
  def with_title_list() do
    html do
      head do
        meta charset: "utf-8"
        meta "http-equiv": "X-UA-Compatible", content: "IE=edge"
        meta name: "viewport", content: "width=device-width, initial-scale=1"
        meta name: "description", content: "result type benchmarking"
        meta name: "author", content: "zambal"
      end
      body do
        h2 String.capitalize("lists")
        title_list title: "Fruit", items: [
          "Strawberry",
          "Banana",
          "Apple",
          "Orange",
        ]
      end
    end
  end

  def with_title_lists() do
    title_list title: "Fruit", items: [
      "Strawberry",
      "Banana",
      "Apple",
      "Orange",
    ]

    html do
      head do
        meta charset: "utf-8"
        meta "http-equiv": "X-UA-Compatible", content: "IE=edge"
        meta name: "viewport", content: "width=device-width, initial-scale=1"
        meta name: "description", content: "result type benchmarking"
        meta name: "author", content: "zambal"
      end
      body do
        h2 String.capitalize("lists")
        title_list title: "Fruit", items: [
          "Strawberry",
          "Banana",
          "Apple",
          "Orange",
        ]
        title_list title: "Programming Languages", items: [
          "C",
          "Java",
          "Erlang",
          "Elixir",
          "Javascript",
        ]
        title_list title: "Countries", items: [
          "Netherlands",
          "Germany",
          "Denmark",
          "Poland",
        ]
        title_list title: "Planets", items: [
          "Mercury",
          "Venus",
          "Earth",
          "Mars",
        ]
      end
    end
  end
end

defmodule EexMarkup do
  defmodule EexView do
    use Phoenix.View, root: "bench", namespace: EexBenchmark
  end

  def with_lists do
    Phoenix.View.render(EexView, "lists.html", [])
  end

  def with_simple_lists do
    Phoenix.View.render(EexView, "simple_lists.html", [])
  end

  def with_title_list do
    Phoenix.View.render(EexView, "title_list.html", [])
  end

  def with_title_lists do
    Phoenix.View.render(EexView, "title_lists.html", [])
  end
end

defmodule Main do
  import ExProf.Macro

  def do_benchmark() do
    Benchee.run(
      %{
        lists_with_taggart: &TaggartMarkup.with_lists/0,
        lists_with_eex: &EexMarkup.with_lists/0,    
      })

    Benchee.run(
      %{
        simple_lists_with_taggart: &TaggartMarkup.with_simple_lists/0,
        simple_lists_with_eex: &EexMarkup.with_simple_lists/0,    
      })

    Benchee.run(
      %{
        title_list_with_taggart: &TaggartMarkup.with_title_list/0,
        title_list_with_eex: &EexMarkup.with_title_list/0,    
      })

    Benchee.run(
      %{
        title_lists_with_taggart: &TaggartMarkup.with_title_lists/0,
        title_lists_with_eex: &EexMarkup.with_title_lists/0,    
      })
  end

  def run_taggart() do
    for i <- 1..1000 do
      TaggartMarkup.with_lists()
    end
    # simple_lists_with_taggart: &TaggartMarkup.with_simple_lists/0,
    # title_list_with_taggart: &TaggartMarkup.with_title_list/0,
    # title_lists_with_taggart: &TaggartMarkup.with_title_lists/0,
  end

  def do_taggart_eprof() do
    profile do
      run_taggart()
    end    
  end

  def do_taggart_fprof() do
    :fprof.apply(&run_taggart/0, [])
    :fprof.profile()
    :fprof.analyse([sort: :own,
                    totals: true,
                    callers: true,
                    details: true])
    Mix.Shell.IO.cmd "mkdir -p perf"
    Mix.Shell.IO.cmd "mv fprof.trace perf/"
  end

  def do_taggart_eflame() do
    svg_file = "perf/flame.svg"
    
    :eflame.apply(&run_taggart/0, [])
    Mix.Shell.IO.info "Generating SVG flamegraph..."
    Mix.Shell.IO.cmd "mkdir -p perf"
    Mix.Shell.IO.cmd "mv stacks.out perf/"
    Mix.Shell.IO.cmd "sort perf/stacks.out | deps/eflame/stack_to_flame.sh > #{svg_file}"
    Mix.Shell.IO.info svg_file
  end
end

case System.argv do
  ["profile", "eprof"] ->
    Main.do_taggart_eprof()

  ["profile", "fprof"] ->
    Main.do_taggart_fprof()

  ["profile", "eflame"] ->
    Main.do_taggart_eflame()

  ["benchmark"] ->
    Main.do_benchmark()

  _ ->
    IO.puts("Usage: mix run bench/run.ex <benchmark | profile eprof | profile fprof | profile eflame>")
    :erlang.halt(1)
end
