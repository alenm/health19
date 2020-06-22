defmodule Health.Repo.Migrations.CreateUniqueIndexOnDateReports do
  use Ecto.Migration

  def up do
      create unique_index(:date_reports, [:location_id, :date], name: :date_reports_index)
  end


  def down do
    execute """
    DROP INDEX date_reports_index;
    """
  end

end
