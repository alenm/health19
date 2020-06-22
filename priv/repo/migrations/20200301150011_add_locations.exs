defmodule Health.Repo.Migrations.AddLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      # My own labels for tracking
      # ------------------------------------------
      add :iso_code,              :string
      add :label_city,            :string
      add :label_prov_state,      :string
      add :label_country_region,  :string
      add :special_note,          :string
      # ------------------------------------------
      # Part of the original CSV
      add :prov_state, :string
      add :country_region, :string
      add :lat, :float
      add :lng, :float
    end
  end
end
