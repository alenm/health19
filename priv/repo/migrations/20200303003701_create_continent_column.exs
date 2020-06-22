defmodule Health.Repo.Migrations.CreateContinentColumn do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :continent, :string
    end
  end

  def down do
    alter table(:locations) do
      remove :continent
    end
  end

end
