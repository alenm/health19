defmodule Health.Repo.Migrations.CreateDateReportLagStats do
  use Ecto.Migration

    #  https://www.postgresqltutorial.com/postgresql-materialized-views/
    # --  CREATE date_report_lag_stats 
    # --  this will be for counting up the latest records for 
    # --  confirmed, recovered and deaths
    
    def up do
      execute """
      CREATE VIEW date_report_lag_stats AS
      select t.location_id,
      t.date,
      -- confirmed stats
      --
      t.confirmed,
      COALESCE(t.confirmed_yesterday, 0) as confirmed_yesterday,
      COALESCE((t.confirmed - t.confirmed_yesterday), 0) as confirmed_daily_delta,
      COALESCE(case when (t.confirmed_yesterday - t.confirmed) is not null
      and t.confirmed_yesterday <> 0
      then round (100.0 * (t.confirmed - t.confirmed_yesterday) / NULLIF(t.confirmed_yesterday,0), 2)
      end, 0.00) as "confirmed_daily_delta_pct",
      -- recovered stats
      -- 
      t.recovered,
      COALESCE(t.recovered_yesterday, 0) as recovered_yesterday,
      COALESCE((t.recovered - t.recovered_yesterday), 0) as recovered_daily_delta,
      COALESCE(case when (t.recovered_yesterday - t.recovered) is not null
      and t.recovered_yesterday <> 0
      then round (100.0 * (t.recovered - t.recovered_yesterday) / NULLIF(t.recovered_yesterday,0), 2)
      end, 0.00) as "recovered_daily_delta_pct",
      -- death stats
      -- 
      t.death,
      COALESCE(t.death_yesterday, 0) as death_yesterday,	
      COALESCE((t.death - t.death_yesterday), 0) as death_daily_delta,
      COALESCE(case when (t.death_yesterday - t.death) is not null
      and t.death_yesterday <> 0
      then round (100.0 * (t.death - t.death_yesterday) / NULLIF(t.death_yesterday,0), 2)
      end, 0.00) as "death_daily_delta_pct"
    from (
    SELECT
      location_id,
      DATE,
      confirmed,
      recovered,
      death,
      -- PARTION BY clause distributes rows into location groups (or partitions) specified by location_id
      LAG(confirmed, 1) OVER(PARTITION BY location_id ORDER BY location_id ASC, DATE ASC) AS confirmed_yesterday,
      LAG(recovered, 1) OVER(PARTITION BY location_id ORDER BY location_id ASC, DATE ASC) AS recovered_yesterday,
      LAG(death, 1) OVER(PARTITION BY location_id ORDER BY location_id ASC, DATE ASC) AS death_yesterday
    FROM
      date_reports
    GROUP BY
      location_id,
      DATE,
      confirmed,	
      recovered,
      death		
    ORDER BY
      location_id ASC,
      DATE ASC
    ) as t 
      """
      
    flush();
    
end


  def down do
    execute "DROP VIEW date_report_lag_stats;"
  end



end
