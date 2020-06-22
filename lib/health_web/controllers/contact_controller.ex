defmodule HealthWeb.ContactController do
    use HealthWeb, :controller
    alias Health.Reports

    action_fallback HealthWeb.FallbackController

    @days_ago 14

    def index(conn, _params) do
      with {:ok, results} <- Reports.get_lag_reports("it", @days_ago) do
        render(conn, "index.html", data: results)
      end
    end

end




    