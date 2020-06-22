defmodule Health.Reports.LagStatReportTest do
    use Health.DataCase
  
    alias Health.Reports.LagStatReport
  
    # TODO: Need to finish writing this test
    describe "%Reports.LagStatReport{}" do
  
        @valid_location %{id: 1, iso_code: "cn-bj", label_city: "",  label_prov_state: "Beijing", label_country_region: "Mainland China", special_note: "", prov_state: "Beijing", country_region: "Mainland China", lat: 31.8257, lng: 117.2264, continent: "asia", continent_iso_code: "as"}
        @valid_attr %{
            location: @valid_location, 
            reports_duration: %{start: ~D[2020-01-01], end_date: ~D[2020-01-08], days_ago: 7 },
            latest_report_sum: %{cofirmed: 200, recovered: 200, death: 100},
            confirmed: [%{
                date: ~D[2020-01-01],
                current: 100, 
                yesterday: 100,
                daily_delta: 100,
                daily_delta_pct: 0.00
            }],
            recovered: [%{
                date: ~D[2020-01-01],
                current: 100, 
                yesterday: 100, 
                daily_delta: 100,
                daily_delta_pct: 0.00
            }],
            death: [%{
                date: ~D[2020-01-01],
                current: 100, 
                yesterday: 100, 
                daily_delta: 100,
                daily_delta_pct: 0.00
            }]
        }
        
      test "create a valid report" do
        assert %LagStatReport{} = LagStatReport.changeset(%LagStatReport{}, @valid_attr)
      end

    end
  end
