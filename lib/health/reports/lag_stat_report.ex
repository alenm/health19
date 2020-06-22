defmodule Health.Reports.LagStatReport do

    @moduledoc """
    This modules data comes from the `:date_report_lag_stats`
    talbe view and is used for generating common stats.

    The reports are provided at a region level and looked up
    by a known `iso-code`.

    If you want something one level higher you need to look
    at the `GroupedLagStatReport` which takes a list of 
    `LagStatReport` reports and the summarizes them into one.
    """
    import Ecto.Changeset
    use Ecto.Schema

    alias Health.Reports.LagStatReport
    alias Health.Location

   
    embedded_schema do
        embeds_one :location, Location
        field :reports_duration,  :map
        field :latest_report_sum, :map
        field :confirmed,       {:array, :map}
        field :recovered,       {:array, :map}
        field :death,           {:array, :map}
    end


    def changeset(%LagStatReport{} = stat_report, params) do
        stat_report
        |> cast(params, [:confirmed, :recovered, :death])
        |> cast_embed(:location)
        |> cast_reports_duration()
        |> cast_stats()
        |> apply_changes
    end

    @doc """
    Pass in a Repo result from a `Location` with `DateReportLagStats`
    and this function will convert it into a list of [%Health.Reports.LagStatReport{}]
    """
    def from_locations(repo_results) do
        repo_results
        |> prepare_for_changeset
        |> create_list_of_changesets
    end

    @doc """
    Takes a list of results of `DateLagReports` and starts to sum and merge
    numbers into a structure of params that will be used for a changeset
    """
    def prepare_for_changeset(results) do
        Enum.map(results, fn(record) -> 
            Map.get(record, :date_report_lag_stats)
            |> Enum.reduce(%{confirmed: [], recovered: [], death: []}, fn(record, acc) -> 
                acc
                |> Map.put(:confirmed, [ record.confirmed | acc.confirmed])
                |> Map.put(:recovered, [ record.recovered | acc.recovered])
                |> Map.put(:death, [ record.death | acc.death])
            end)
            |> Map.update!(:confirmed, fn(list)-> Enum.reverse(list) end)
            |> Map.update!(:recovered, fn(list)-> Enum.reverse(list) end)
            |> Map.update!(:death, fn(list)-> Enum.reverse(list) end)
            |> Map.put_new(:location, create_location_params(record))
        end)
    end

    # Repo.all always returns a list, so we pass in a list
    defp create_list_of_changesets(params) do
        Enum.map(params, fn(param) -> 
            changeset(%LagStatReport{}, param)
        end)
        |> Enum.sort_by(fn(item) -> item.latest_report_sum.confirmed end,  &>=/2)
    end

    defp create_location_params(param) do
        Map.drop(param, [:date_reports, :date_report_lag_stats, :__meta__])
        |> Map.from_struct
    end

    # Changeset stuff ------------------------------------------------------------

    defp cast_reports_duration(changeset) do
        dates         = Map.get(changeset.params, "confirmed")
        start_date    = dates |> List.first |> Map.get(:date)
        end_date      = dates |> List.last |> Map.get(:date)
        put_change(changeset, :reports_duration, %{start: start_date, end_date: end_date, days_ago: Date.diff(end_date, start_date)})
    end

    defp cast_stats(changeset) do
        confirmed_stat = Map.get(changeset.params, "confirmed") |> List.last |> Map.get(:current)
        recovered_stat = Map.get(changeset.params, "recovered") |> List.last |> Map.get(:current)
        death_stat     = Map.get(changeset.params, "death") |> List.last |> Map.get(:current)

        latest_stats = 
            %{}
            |> Map.put_new(:confirmed, confirmed_stat)
            |> Map.put_new(:recovered, recovered_stat)
            |> Map.put_new(:death, death_stat)

        put_change(changeset, :latest_report_sum, latest_stats)
    end


end