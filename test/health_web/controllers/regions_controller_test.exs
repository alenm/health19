defmodule HealthWeb.RegionsControllerTest do
    use HealthWeb.ConnCase

    alias Health.{Location, DateReport, Repo}

    setup [:create_data]

    test "GET /regions", %{conn: conn, data: _data} do
      conn = get(conn, "/regions")
      assert html_response(conn, 200) =~ "Health19 – Regions"
    end

    test "GET /regions/as", %{conn: conn, data: _data} do
      conn = get(conn, "/regions/as")
      assert html_response(conn, 200)
    end

    test "GET /regions/as/cn-ah", %{conn: conn, data: _data} do
      conn = get(conn, "/regions/as/cn-ah")
      assert html_response(conn, 200)
    end


    @create_attr [
      %Location{id: 1, iso_code: "cn-ah", label_city: "",  label_prov_state: "Anhui", label_country_region: "Mainland China", special_note: "", prov_state: "Anhui", country_region: "Mainland China", lat: 31.8257, lng: 117.2264, continent: "asia", continent_iso_code: "as"},
      %DateReport{location_id: 1, date: ~D[2020-02-04], confirmed: 400, recovered: 20, death: 10}
    ]
  
    defp create_data(_) do
     [location, date_report] = Enum.map(@create_attr, fn(x) -> Repo.insert!(x) end)
     {:ok, data: [location, date_report]}
    end  
    
  end
  