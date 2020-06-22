defmodule Health.Reports.SMA_Report do

    # TODO: Work in progress
    # ----------------
    # Simple Moving Average Report (SMA)
    # ----------------
    
    import Ecto.Changeset
    use Ecto.Schema

    alias Health.Stats.SMA
    alias Health.Reports.{LagStatReport, SMA_Report}
    alias Health.Location

    embedded_schema do
        embeds_one :location, Location
        field :report_type,       :string
        field :period_days,       :integer
        field :data,              {:array, :map}
        field :title,             :string
    end

    @attr ~w[report_type period_days data title]a

    def changeset(%SMA_Report{} = sma, params) do
        sma
        |> cast(params,  @attr)
        |> cast_embed(:location)
        |> validate_required(@attr)
        |> apply_changes
    end

    @doc """
    Returns a simple moving average by passing in a LagStatReport and 
    the type of report you want `:confirmed`, `:recovered` or `:death`

    ## Params
    `report`: Must be a %LagStatReport{}
    `report_type`: You can only pass in [:confirmed, :recovered, :death]
    `days`: Default is 10 days

    iex > {:ok, result} = Health.Reports.get_lag_reports("it")
    iex > lsr_report = List.first(result)
    iex > SMA.from_lag_stat_report(lsr_report, :confirmed)
    ...
    %Health.Stats.SMA{data: [...], location: %{}, period_days: 10, report_type: "Confirmed", title: "Confirmed Cases: Simple Moving Average (Period 10 days)"}
    """
    def from_lag_stat_report(report, report_type, days \\ 10)
    def from_lag_stat_report(%LagStatReport{} = obj, report_type, days) when report_type in [:confirmed, :recovered, :death] do
        %{}
        |> Map.put_new(:location, Map.from_struct(obj.location))
        |> Map.put_new(:report_type, report_type_title(report_type))
        |> Map.put_new(:period_days, days)
        |> Map.put_new(:data, create_sma_report(Map.get(obj, report_type), days))
        |> Map.put_new(:title, create_title(report_type, days))
        |> create_changeset()
     end

     defp create_sma_report(reports, days) do
        dates_confirmed =
            Enum.map(reports, fn(item) -> Map.take(item, [:current, :date]) end)

        {:ok, sma } =
            dates_confirmed
            |> Enum.map(fn(item) -> item.current end)
            |> SMA.sma(days)

        merged =
            Enum.drop(dates_confirmed, days - 1)
            |> Enum.zip(sma) 
            |> Enum.map(fn({a,b}) -> 
                Map.merge(a,b) 
            end)
        
        merged
     end

     defp report_type_title(report) do
         case report do
             :confirmed -> "Confirmed"
             :recovered -> "Recovered"
             :death     -> "Death"
         end
     end

     defp create_title(report_type, days) do
         "#{report_type_title(report_type)} Cases: Simple Moving Average (Period #{days} days)"
     end

     defp create_changeset(params) do
         changeset(%SMA_Report{}, params)
     end

end