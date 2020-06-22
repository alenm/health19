defmodule Health.Reports do
    
    @moduledoc """
    The Reports context module

    This returns some common reports.
    1. LagStatReport: this type of report has lots of meta data on `confirmed`, `recovered` and `death`
    cases along with some statistics around the lag of each days activity.
    """

    import Ecto.Query
    use Ecto.Schema

    alias Health.DateReportLagStats
    alias Health.Reports.LagStatReport
    alias Health.Reports.GroupedLagStatReport
    alias Health.Location
    alias Health.Repo

    @default_days_ago 365

    @doc """
    Returns all lag_reports grouped by region name

    ## Parameters
    * days - will return x days ago of records. Default is 365.

    Returns `{:not_found, msg}` if the Lag report does not exist.

    ## Examples

        iex> get_all_lag_reports()
        [:ok, [%Health.Reports.GroupedLagStatReport{}]]
        
        iex> get_all_lag_reports(10)
        [:ok, [%Health.Reports.GroupedLagStatReport{}]]

    """

    def get_all_lag_reports(days \\ @default_days_ago) do
        Location
        |> with_lag_reports(days)
        |> Repo.all
        |> LagStatReport.from_locations
        |> GroupedLagStatReport.from_lag_stat_reports()
        |> to_tuple
    end

    @doc """
     Returns the list of lag_reportsby a known iso code

    ## Parameters
    * iso_code - provide a known iso_code
    * days - will return x days ago of records

    Returns `{:not_found, msg}` if the Lag report does not exist.

    ## Examples

        iex> get_lag_reports("it")
        [:ok, [%LagStatReport{}]]
        

        iex> get_lag_reports("it", 10)
         [:ok, [%LagStatReport{}]]

        iex> get_lag_reports("zoo")
         {:not_found, msg}

    """
    def get_lag_reports(iso_code, days \\ @default_days_ago) do
        Location.by_iso(iso_code)
        |> with_lag_reports(days)
        |> Repo.all
        |> LagStatReport.from_locations
        |> to_tuple
    end

    @doc """
     Returns the list of lag_reports by continent iso code

    ## Parameters
    * iso_code - provide a known continent iso_code
    * days - will return x days ago of records

    Returns `{:not_found, msg}` if the Lag report does not exist.

    ## Examples

        iex> get_lag_reports("na")
        [:ok, [%GroupedLagStatReport{}]]
        

        iex> get_lag_reports("na", 10)
         [:ok, [%GroupedLagStatReport{}]]

        iex> get_lag_reports("zoo")
         {:not_found, msg}
    """

    def get_continent_lag_reports(continent_iso_code, days \\ @default_days_ago)
    def get_continent_lag_reports(continent_iso_code, days) when continent_iso_code in ["as", "af", "oc", "eu", "na", "sa"] do
        Location.by_continent_iso(continent_iso_code)
        |> with_lag_reports(days)
        |> Repo.all
        |> LagStatReport.from_locations
        |> GroupedLagStatReport.from_lag_stat_reports()
        |> to_tuple
    end
    def get_continent_lag_reports(_continent_iso_code, _days), do: by_continent_iso_params_error()
    def by_continent_iso_params_error(), do: raise ArgumentError, "Must pass in one of the following keys 'as', 'af', 'oc', 'eu', 'na','sa'. For example get_continent_lag_report(iso_code: 'na', days_ago: 10)"


   defp days_ago(days) do
        negative_days = days - (days * 2) # need the number to be negative
        (from dr in Health.DateReport, select: max(dr.date))
        |> Repo.one
        |> Date.add(negative_days)
   end

   defp with_lag_reports(query, days) do
        date = days_ago(days + 1) # 1 is added because we count today as a day
        date_reports = 
            from dr in DateReportLagStats, where: dr.date > ^date,
            select: %{
                confirmed: %{
                    date: dr.date,
                    current: dr.confirmed, 
                    yesterday: dr.confirmed_yesterday, 
                    daily_delta: dr.confirmed_daily_delta,
                    daily_delta_pct: dr.confirmed_daily_delta_pct
                },
                recovered: %{
                    date: dr.date,
                    current: dr.recovered, 
                    yesterday: dr.recovered_yesterday, 
                    daily_delta: dr.recovered_daily_delta,
                    daily_delta_pct: dr.recovered_daily_delta_pct
                },
                death: %{
                    date: dr.date,
                    current: dr.death, 
                    yesterday: dr.death_yesterday, 
                    daily_delta: dr.death_daily_delta,
                    daily_delta_pct: dr.recovered_daily_delta_pct
                }
            }
        from query, preload: [date_report_lag_stats: ^date_reports]
    end


    defp to_tuple(result) do
        case result do
            []      -> {:not_found, "The results are empty. Check the spelling."}
            nil     -> {:emtpty, "Nothing. Check the spelling."}
            result  -> {:ok, result}
        end
    end


end