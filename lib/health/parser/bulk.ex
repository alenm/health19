defmodule Health.Parser.Bulk do
    
    alias Parser.CSV
    alias Health.{Repo,Location}
   
    def bulk_start do
        [
            {"/Users/alen/Desktop/COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv", :confirmed},
            {"/Users/alen/Desktop/COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv", :recovered},
            {"/Users/alen/Desktop/COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv", :death}
        ]
        |> Enum.map(fn({file, report}) -> 
            start(file, report)
        end)
    end


    def start(filepath, type_of_report) when type_of_report in [:confirmed, :recovered, :death] do
        CSV.timeseries(filepath, type_of_report)
        |> get_locations
        |> update_location
        |> perform_insert_all(type_of_report)
    end

    def start(filepath, _type_of_report), do: params_error(filepath)
    def start(filepath), do: params_error(filepath)

    @doc """
    Return a list of location with all the date reports in a days key

    iex> [%{location: ..., days: [...]}]
    """
    def get_locations(list) do
        Enum.map(list, fn(item) -> 
            item
            |> Map.put(:location, lookup_or_insert_location_record(item.location))
            |> Map.put(:days, item.days)
        end)
    end

    @doc """
    Look up the location. 
    - If it exist return it
    - If it does not exisit create one and then return it
    """
    def lookup_or_insert_location_record(params) do
        lookup_keywords = 
            Keyword.take(params, [:country_region, :lat, :lng])

        case Repo.get_by(Location, lookup_keywords) do
            nil     -> create_location(params)
            result  -> result
        end
    end

    defp create_location(params) do
       {:ok, result} =
            %Location{} 
            |> Location.changeset(Map.new(params)) 
            |> Repo.insert
        result
    end

    
    @doc """
    Take the location ID and merge it with all the records within the days key
    """
    def update_location(list) do
        Enum.map(list, fn(item) -> 
            item
            |> Map.put(:days, add_location_into_days(item.location, item.days))
        end)
    end

    def add_location_into_days(location, days) do
        Enum.map(days, fn(day) -> 
            [location_id: location.id]
            |> Keyword.merge(day)
            |> Keyword.put(:date, NaiveDateTime.to_date(Keyword.get(day, :date)))
        end)
    end



    @doc """
    Will perform an insert_all on each set location and it's days.
    The `location.days` can be a large set of records. 100 records.
    Imagine 245 locations * 100 records is about 24,5000 records getting inserted.

    This function will need to deal with duplicates as it parses :confirmed, :recovered and :death CSV

    It's important that this is set up 

    Parameters
    - 'list' is a list of maps that contain %{location: ..., days: []}. 
       Each day in the `days` key is a Keyword [location_id: 1, date: ~D[2020-01-01], confirmed: 0].
       
       Please Note: 
       - at the `start/2` function if you passed in filepath_csv, :confirmed
       the day Keyword within the `days` key will look like this [location_id: 1, date: ~D[2020-01-01], confirmed: 0]
       - at the `start/2` function if you passed in filepath_csv, :recovered
       the day Keyword within the `days` key will look like this [location_id: 1, date: ~D[2020-01-01], recovered: 0]
       - at the `start/2` function if you passed in filepath_csv, :death
       the day Keyword within the `days` key will look like this [location_id: 1, date: ~D[2020-01-01], death: 0]

    The date_reports contains an unique index on `location_id` and 'date'. 
    This is important as no location should have duplicate dates.
    Also this allows use to use `insert_all` 'on_conflict'.

    `on_conflict` basically says when you run into doing an update just replace the value of the type of report.
    So it should only replace the values within :confirmed, :recovered, :death.


    """

    def perform_insert_all(list, type_of_report) when type_of_report in [:confirmed, :recovered, :death] do
        Enum.each(list, fn(location) -> 
            Health.Repo.insert_all(Health.DateReport, location.days, on_conflict: {:replace, [type_of_report]}, conflict_target: [:location_id, :date])
        end)
    end

    def perform_insert_all(list, _type_of_report), do: params_error(list)
    def perform_insert_all(list), do: params_error(list)

    def params_error(_filepath_to_csv) do
        raise ArgumentError, 
        message: """
        Missing a parameter for the type of CSV report

        You must pass in the filepath and report type. Type of CSV report are:
        • :confirmed
        • :recovered
        • :death 

        For example

            new(filepath_to_csv, :confirmed)
            or
            new(filepath_to_csv, :recovered)
            or
            new(filepath_to_csv, :death)
        """
    end



    # New bulk insert
    # Get all 3 CSV records
    # Merge them together by locations?? How?
    # Merge each date

    #         query = from d in Health.DateReport, update: [set: [confirmed: fragment("EXCLUDED.confirmed")]]

     # query = from d in Health.DateReport, update: [set: [confirmed: fragment("EXCLUDED.confirmed")]]
    # Repo.insert_all Post, entries, on_conflict: query

    #  Health.Repo.insert_all(Health.DateReport, item.days, on_conflict: {:replace, :confirmed}, conflict_target: []:location_id)

# upsert_query =
#   Counter
#   |> where([o], o.key == fragment("EXCLUDED.key"))
#   |> update(inc: [count: fragment("EXCLUDED.count")])

# Repo.insert_all(Counter, records,
#   on_conflict: upsert_query,
#   conflict_target: [:key],
#   returning: false
# )






end