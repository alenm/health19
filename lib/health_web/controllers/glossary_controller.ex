defmodule HealthWeb.GlossaryController do
    use HealthWeb, :controller

    def index(conn, _params) do
      render(conn, "index.html")
    end


end