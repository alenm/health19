defmodule Health.Repo.Migrations.CreateTallyReportPostgresView do
  use Ecto.Migration

  #  https://www.postgresqltutorial.com/postgresql-materialized-views/

  def up do
      # --  CREATE tally_report 
      # --  this will be for counting up the latest records for 
      # --  confirmed, recovered and deaths
      execute """
        CREATE VIEW tally_reports AS
        select
        id as location_id,
        iso_code, 
        label_country_region,
        label_prov_state,
        label_city,
        special_note,
        continent,
        continent_iso_code,
        COALESCE( p.confirmed, 0) as confirmed,
        COALESCE( p.recovered, 0) as recovered,
        COALESCE( p.death, 0) as death,
        p.date as latest
        from locations
        left join (
            select date, location_id, confirmed, recovered, death
            from date_reports
            where date = (select max(date) from date_reports)
            order by location_id
        ) p on p.location_id = locations.id
        order by location_id asc;
      """
      
    flush();
    
end


  def down do
    execute "DROP VIEW tally_reports;"
  end


end
