defmodule Parser.Scrub do
    
    alias Health.{Repo, Location}
    @doc """
    I would like to improve the naming convention for some of the columns from
    the parsed CSV. So I have this lookup table that will fill in other columns
    once the import has been completed.

    You basically run this once after you have added the CSV of locations

    If you look at the DB and see that that some rows have missing data you
    could trying adding another item in this list
    OR
    you can edit some of the details if it doesn't look correct

    The CSV files of locations come with :lat, :lng, :country_region, :prov_state
    We are using this properties to match and complete everything else

    The csv is located at:
    `/priv/repo/my_locations.csv`

    You run a Mix task called:
    `mix health.scrub` to automate this after the DB has been seeded.

    """

    @lookup_table Parser.Lookup.create()

    def start() do
      Location
      |> Repo.all
      |> Enum.each(fn(item) -> 
        update_location_record_with_details(item)
      end)
    end

    def update_location_record_with_details(%Location{} = model) do
        case find_details(model) do
            nil           -> {:no_update, "No details need to be added"}
            found_record  -> Ecto.Changeset.change(model, found_record) |> Repo.update
        end
    end

    def find_details(model) do
        Enum.find(@lookup_table, fn item -> 
            does_record_exist?(item, model) 
        end)
    end

    @doc """
    Using the lat and lng has that's the most distinct id for a record
    """
    def does_record_exist?(item, model) do
        [a, b] =
            [item, model]
            |> Enum.map(fn(the_map) -> 
                Map.to_list(the_map) |> Keyword.take(~w(prov_state country_region lat lng)a) |> format_record()
            end)
        if a == b do
            true
        else
            false
        end
    end

    # The DB has decimals that are long and they don't match with the static csv
    # The csv only shows the last 4 decimals for lat and lng
    def format_record(record) do
      record
      |> Keyword.replace!(:lat, Float.round(Keyword.get(record, :lat), 4))
      |> Keyword.replace!(:lng, Float.round(Keyword.get(record, :lng), 4))
    end
  


end