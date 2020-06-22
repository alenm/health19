defmodule Health.Repo.Migrations.AddDateReports do
  use Ecto.Migration

  def change do
    create table(:date_reports, primary_key: false) do
      add :location_id, references(:locations, on_delete: :nothing)
      add :date, :date
      add :confirmed, :integer, default: 0
      add :recovered, :integer, default: 0
      add :death, :integer, default: 0
    end
  end
end
