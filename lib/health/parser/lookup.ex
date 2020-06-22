defmodule Parser.Lookup do
    import Ecto.Changeset

    @moduledoc """
    This module creates a temporary look up table using a static CSV
    The CSV contains additional information like iso-codes and continent-iso codes
    that are needed for the application.

    I find that the data has been changing and I use this table to group things to my liking
    """
    alias NimbleCSV.RFC4180, as: CSV
    alias Health.Location

    def create() do
        Application.app_dir(:health, "priv/repo/my_locations.csv")
        |> File.read!() 
        |> CSV.parse_string()
        |> create_location_maps()
    end
    
    @keys ~w(id iso_code label_city label_prov_state label_country_region special_note prov_state country_region lat lng continent continent_iso_code)a
    def create_location_maps(csv_list) do
        Enum.map(csv_list, fn(item) -> 
            Enum.zip(@keys, item)
            |> Enum.into(%{})
            |> build_changeset()
            |> Map.from_struct
            |> Map.delete(:__meta__)
            |> Map.delete(:date_report_lag_stats)
            |> Map.delete(:date_reports)
            |> Map.delete(:id)
        end)
    end


    def build_changeset(attrs) do
        Location.changeset(%Location{}, attrs)
        |> apply_changes
    end

   


end


