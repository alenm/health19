defmodule Mix.Tasks.Health.Seeder do
    use Mix.Task
  
    @shortdoc "Import data for the database"
  
    @moduledoc """
      This task will seed the database based on the latest
    """
  
    def run(_args) do
      Mix.shell.info "Starting to import data..."
      Mix.shell.info "+ ================================================ +"
      Mix.shell.cmd("psql -d health_#{Mix.env} -f #{sql_file()}")
      Mix.shell.info "+ ================================================ +"
      Mix.shell.info "Finished importng of data."
    end
  
    
    defp sql_file do
        Application.app_dir(:health, "priv/repo/seed_data.sql")
    end


  end