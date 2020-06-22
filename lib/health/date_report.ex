defmodule Health.DateReport do

    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    # TODO: The `date` must be unqiue in that you can't have duplicates

    schema "date_reports" do
        field :date, :date
        field :confirmed, :integer, default: 0
        field :recovered, :integer, default: 0
        field :death, :integer, default: 0
        
        belongs_to :location, Health.Location
    end

    def changeset(%Health.DateReport{} = model, params \\ %{}) do
        model
        |> cast(params, [:location_id, :date, :confirmed, :recovered, :death])
        |> validate_required([:location_id, :date])
        |> assoc_constraint(:location)
    end


end