defmodule Health.DateReportLagStatsTest do
    use Health.DataCase
  
    alias Health.{
            DateReportLagStats, 
            Location
          }
  
    describe "date_report_lag_stat" do
    
    @valid_location %Location{id: 2, iso_code: "cn-bj", label_city: "",  label_prov_state: "Beijing", label_country_region: "Mainland China", special_note: "", prov_state: "Beijing", country_region: "Mainland China", lat: 31.8257, lng: 117.2264, continent: "asia", continent_iso_code: "as"}

    # TODO: How do I write a test for a Psotgres Materialized view
    # Test the migration file is there? Test for the attributes?

    @valid_date_report %DateReportLagStats{
        location: @valid_location, 
        date: ~D[2020-01-01], 
        confirmed: 10,  
        confirmed_yesterday: 0, 
        confirmed_daily_delta: 0, 
        confirmed_daily_delta_pct: 0.00, 
        recovered: 10,
        recovered_yesterday: 10,
        recovered_daily_delta: 10,
        recovered_daily_delta_pct: 0.00,
        death: 10,
        death_yesterday: 10,
        death_daily_delta: 10,
        death_daily_delta_pct: 0.00
    }
        
      test "that is contains correct attributes" do
        dr = @valid_date_report
        assert dr.date == ~D[2020-01-01]
        # confirmed
        assert dr.confirmed == 10
        assert dr.confirmed_yesterday == 0
        assert dr.confirmed_daily_delta == 0
        assert dr.confirmed_daily_delta_pct == 0.00
        # recovered
        assert dr.recovered == 10
        assert dr.recovered_yesterday == 10
        assert dr.recovered_daily_delta == 10
        assert dr.recovered_daily_delta_pct == 0.00
        # death
        assert dr.death == 10
        assert dr.death_yesterday == 10
        assert dr.death_daily_delta == 10
        assert dr.death_daily_delta_pct == 0.00
      end

    end
  end

