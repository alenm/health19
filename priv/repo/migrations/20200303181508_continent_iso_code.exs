defmodule Health.Repo.Migrations.ContinentIsoCode do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :continent_iso_code, :string
    end
  end

  def down do
    alter table(:locations) do
      remove :continent_iso_code
    end
  end
end
