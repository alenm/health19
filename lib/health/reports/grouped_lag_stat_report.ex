defmodule Health.Reports.GroupedLagStatReport do

     @moduledoc """
    The `GroupedLagStatReport` module. This module provides a summary report
     on a collection of `LagStatReports`.

    The main data for this module is all the results of `LagStatReports`.
    This modules groups the records by the first two letters of the iso-code.

    This grouping then allows the module to summarize by the group key which
    is the first two letters of it's iso code.

    The structure is almost the same, except the LagStatReports
    stats `confirmed`, `recovered`, `death` get summed into one.
    The `latest_report_sum` get summed up too.

    The reports are mostly looked up
    by a known `continent_iso_code`..
    """

    use Ecto.Schema
    import Ecto.Changeset
  
    alias Health.Reports.GroupedLagStatReport

    @primary_key false
  
    embedded_schema do
        # Location attr
        field :location,              :map
        # field :iso_code,              :string
        # field :label_country_region,  :string
        # field :special_note,          :string
        # field :continent,             :string
        # field :continent_iso_code,    :string
        #  attr
        field :reports_duration,  :map
        field :latest_report_sum, :map
        field :confirmed,       {:array, :map}
        field :recovered,       {:array, :map}
        field :death,           {:array, :map}
    end


    @location_keys ~w(location)a
    @reporting_keys ~w(reports_duration latest_report_sum confirmed recovered death)a

    def changeset(%GroupedLagStatReport{} = national, attrs) do
      national
      |> cast(attrs, @location_keys ++ @reporting_keys)
      |> modify_iso_code
      |> apply_changes
    end

    @doc """
    Modifies the iso code string to 2 characters. It makes it easier to group
    by two characters
    """ 
    def modify_iso_code(changeset) do
        location = changeset.changes.location
        iso_code = location.iso_code
        location = put_in(location, [:iso_code], trim_iso_code(iso_code))
        put_change(changeset, :location, location)
    end
      
    defp trim_iso_code(iso) do
       String.slice(iso, 0..1)
    end
    
    @doc """
    Provide a list of `LagStatReports` and it will merge and summarize 
    the reports into summary.

        `Location
        |> with_lag_reports(days)
        |> Repo.all
        |> LagStatReport.from_locations`

    """ 
    # You will have the following keys
    # [:confirmed, :data, :death, :latest_report_sum, :params, :recovered, :region, :reports_duration]
    def from_lag_stat_reports(results) do
        results
        |> tag_each_record_with_two_string_iso
        |> group_by_iso_codes
        |> prep_params
        |> sum_latest_report_sum
        |> sum_remaining_records
        |> prepare_and_pass_into_changeset
    end
    
    # Functions below are all dealing with preparing, parsing the records into some params 
    # for the changeset to be used
    defp tag_each_record_with_two_string_iso(results) do
        Enum.map(results, fn(item) -> 
            Map.put_new(item, :iso_code, trim_iso_code(item.location.iso_code))
        end)
    end


    defp group_by_iso_codes(results) do
        Enum.group_by(results, fn(item) -> item.iso_code end)
    end


    defp prep_params(results) do
        keys = Map.keys(results)
        Enum.map(keys, fn(key) -> 
            records      = Map.get(results, key)
            first_record = List.first(records)
            %{}
            |> Map.put_new(:location, Map.take(first_record.location, ~w(iso_code label_country_region special_note continent continent_iso_code)a))
            |> Map.put_new(:reports_duration, first_record.reports_duration)
            |> Map.put_new(:data, records)
            |> Map.put_new(:latest_report_sum, Enum.map(records, fn(item) -> item.latest_report_sum end))
            |> Map.put_new(:confirmed, Enum.map(records, fn(item) -> item.confirmed end) |> List.flatten)
            |> Map.put_new(:recovered, Enum.map(records, fn(item) -> item.recovered end) |> List.flatten)
            |> Map.put_new(:death, Enum.map(records, fn(item) -> item.death end) |> List.flatten)
        end)
    end

    defp sum_latest_report_sum(results) do
        Enum.map(results, fn(item) -> 
            Map.put(item, :latest_report_sum, sum_all_latest_report_sum(item.latest_report_sum))
        end)
    end

    def sum_all_latest_report_sum(results) do
        
        Enum.reduce(results, %{confirmed: 0, death: 0, recovered: 0}, fn(item, acc) -> 
            acc
            |> Map.put(:confirmed, item.confirmed + acc.confirmed)
            |> Map.put(:death, item.death + acc.death)
            |> Map.put(:recovered, item.recovered + acc.recovered)
        end)
    end


    defp sum_remaining_records(results) do
        Enum.map(results, fn(item) -> 
            item
            |> Map.put(:confirmed, sum_records(item.confirmed))
            |> Map.put(:recovered, sum_records(item.recovered))
            |> Map.put(:death, sum_records(item.death))
        end)
    end

    defp sum_records(records) do
        grouped = Enum.group_by(records, fn(item) -> item.date end)
        dates   = Map.keys(grouped)
        Enum.map(dates, fn(date) -> 
            Map.get(grouped, date)
            |> sum_record(date)
        end)
    end

    defp sum_record(list, date) do
        Enum.reduce(list, %{current: 0, daily_delta: 0, date: date, yesterday: 0}, fn(item, acc) -> 
                acc
                |> Map.put(:current, item.current + acc.current)
                |> Map.put(:daily_delta, item.daily_delta + acc.daily_delta)
                |> Map.put(:yesterday, item.yesterday + acc.yesterday)
        end)
    end

    defp prepare_and_pass_into_changeset(results) do
        Enum.map(results, fn(item) -> 
            changeset(%GroupedLagStatReport{}, item)
        end)
        |> Enum.sort_by(fn(item) -> item.latest_report_sum.confirmed end,  &>=/2)
    end


end