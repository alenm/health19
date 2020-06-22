defmodule Health.Reports.MergeReports do

    @moduledoc """
    Helper module that will summarize lists of LagStatReports or
    list of GroupedLagStatReport.
    """
    import Ecto.Changeset
    use Ecto.Schema
   
    embedded_schema do
        field :location, :map
        field :reports_duration,  :map
        field :latest_report_sum, :map
        field :confirmed,       {:array, :map}
        field :recovered,       {:array, :map}
        field :death,           {:array, :map}
    end

    @keys ~w(location reports_duration latest_report_sum confirmed recovered death)a

    def changeset(%Health.Reports.MergeReports{} = report, params) do
        report
        |> cast(params, @keys)
        |> apply_changes
    end


    def from_reports(list_of_reports) do
        report 
            = List.first(list_of_reports)
        
        merge_records(list_of_reports)
        |> get_reports_duration(report)
        |> get_location(report)
        |> create_changeset()
    end

    def create_changeset(params) do
        %Health.Reports.MergeReports{}
        |> changeset(params)
    end

    def merge_records(list) do
        Enum.reduce(list, %{confirmed: [], death: [], recovered: [], latest_report_sum: []}, fn(record, acc) -> 
            acc
            |> Map.put(:confirmed, [record.confirmed | acc.confirmed])
            |> Map.put(:recovered, [record.recovered | acc.recovered])
            |> Map.put(:death, [record.death | acc.death])
            |> Map.put(:latest_report_sum, [record.latest_report_sum | acc.latest_report_sum])
        end)
        |> Map.update!(:confirmed, fn(list)-> List.flatten(list) |> sum_records() end)
        |> Map.update!(:recovered, fn(list)-> List.flatten(list) |> sum_records() end)
        |> Map.update!(:death, fn(list)-> List.flatten(list) |> sum_records() end)
        |> Map.update!(:latest_report_sum, fn(list)-> List.flatten(list) |> sum_latest_report_sum() end)
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


    defp sum_latest_report_sum(records) do
        Enum.reduce(records, %{confirmed: 0, recovered: 0, death: 0}, fn(item, acc) -> 
            acc
            |> Map.put(:confirmed, item.confirmed + acc.confirmed)
            |> Map.put(:recovered, item.recovered + acc.recovered)
            |> Map.put(:death, item.death + acc.death)
        end)
    end

    defp get_reports_duration(map, obj) do
        map
        |> Map.merge(Map.take(obj, [:reports_duration]))
        
    end

    defp get_location(map, obj) do
        map
       |> Map.merge(Map.take(obj, [:location]))
    end


end