defmodule Health.DateReportTest do
    use Health.DataCase
  
    alias Health.DateReport
    alias Health.Repo
  
    describe "date_report" do
  
        @valid_location %Health.Location{id: 2, iso_code: "cn-bj", label_city: "",  label_prov_state: "Beijing", label_country_region: "Mainland China", special_note: "", prov_state: "Beijing", country_region: "Mainland China", lat: 31.8257, lng: 117.2264, continent: "asia", continent_iso_code: "as"}
        @valid_date_report %Health.DateReport{location: @valid_location, location_id: 2, date: ~D[2020-02-04], confirmed: 400, recovered: 20, death: 10}
        
      test "create_date_report/1 with valid data creates a user" do
        assert {:ok, %DateReport{} = dr} = DateReport.changeset(@valid_date_report) |> Repo.insert
        assert dr.date == ~D[2020-02-04]
        assert dr.confirmed == 400
        assert dr.recovered == 20
        assert dr.death == 10
      end

    end
  end
