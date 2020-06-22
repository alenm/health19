defmodule Mix.Tasks.Health.Scrub do
    use Mix.Task
    alias Health.Repo

    @shortdoc "Scrubs all location data with additional information"

    def run(_args) do
      [:postgrex, :ecto]
        |> Enum.each(&Application.ensure_all_started/1)
      Repo.start_link
      Parser.Scrub.start()
      IO.puts "Task completed successfully."
    end
  

  end

