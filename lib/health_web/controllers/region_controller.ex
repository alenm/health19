defmodule HealthWeb.RegionsController do
    use HealthWeb, :controller
    alias Health.Reports

    action_fallback HealthWeb.FallbackController

    @days_ago 14

    def index(conn, _params) do
      with {:ok, results} <- Reports.get_all_lag_reports(@days_ago) do
        render(conn, "index.html", data: results, duration: get_duration(results))
      end
    end

    def show(conn, %{"continent_iso" => _slug, "region_iso" => region_iso}) do
      with {:ok, results} <- Reports.get_lag_reports(region_iso, @days_ago) do
          default_view = get_cookie_list_preference(conn)
          render(conn, "show_region.html", data: results, duration: get_duration(results), type_of_view: default_view)
      end
    end

    def show(conn, %{"continent_iso" => continent_iso}) do
      with {:ok, results} <- Reports.get_continent_lag_reports(continent_iso, @days_ago) do
        render(conn, "show.html", data: results, continent_iso: continent_iso, breadcrumb: get_breadcrumb(results), duration: get_duration(results))
      end
    end

    # Private -----------

    defp get_cookie_list_preference(conn) do
      result = 
        Plug.Conn.fetch_cookies(conn) 
        |> Map.get(:cookies) 
        |> Map.get("viewing_pref") # This is the name of the key
      case result do
        nil -> 
          "list"
        _   -> 
          result
      end
    end


    defp get_duration(list) do
      List.first(list) |> Map.take([:reports_duration])
    end

    defp get_breadcrumb(list) do
      List.first(list) 
      |> Map.get(:location)
      |> Map.take([:continent, :continent_iso_code])
    end
    
end
