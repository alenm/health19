defmodule Parser.CSV do
    
    import Ecto.Query
    alias Health.{Repo,Location, DateReport}
    alias NimbleCSV.RFC4180, as: CSV
       
    # To start Parser.CSV.timseries(file_path, :confirmed) |> Parser.CSV.parser()

    def timeseries(filepath_to_csv, type_of_report) when type_of_report in [:confirmed, :recovered, :death] do
   
        filepath = File.read!(filepath_to_csv) 

        # The header contains the dates
        {header, _body} = 
            filepath 
            |> String.split("\n")
            |> List.pop_at(0)

        body =
            filepath
            |> CSV.parse_string()

        days = 
            parse_csv_header_into_dates(header)
      
        Enum.map(body, fn(row) -> 
            parse_location(row, days, type_of_report)
        end)
    end

    def timeseries(filepath_to_csv, _type_of_report), do: params_error(filepath_to_csv)
    def timeseries(filepath_to_csv), do: params_error(filepath_to_csv)

    def parse_location(row, days, type_of_report) do

        location_details = 
            row |> Enum.take(4)
        
        days_data = 
            row 
            |> Enum.drop(4) 
            |> Enum.map(fn(item) -> 
                {num, _} = Integer.parse(item) # Parse day data into Integer
                num  
            end)

        merged_days_data = 
            Enum.zip(days, days_data)
            |> Enum.map(fn({date, value}) -> 
                create_days_keyword_list(date, value, type_of_report)
            end)

        %{ 
            location: create_location_keyword_list(location_details),
            days: merged_days_data 
        }

    end


    def parse(list) when is_list(list) do
        Enum.each(list, fn(item) -> 
            parse(item)
        end)
    end

    # def parse(list) when is_list(list) do
    #     list
    #     |> Stream.chunk_every(10)
    #     |> Task.async_stream(&Parser.CSV.parse/1, max_concurrency: 4, timeout: :infinity)
    #     |> Enum.map(fn({:ok, result}) -> result end)
    #     |> IO.inspect
    # end

    #Task.async_stream(collection, Parser.CSV.parse/1, max_concurrency: 8, timeout: 7000)
    # Enum.each(list, fn(item) -> 
    #     parse(item)
    # end)

    # |> Stream.map(fn n ->
    #     case n do
    #       [seq,first,last,email,digit] -> %{seq: seq, first: first}
    #       _ -> ""
    #     end
    #     end)
    #   |> Stream.chunk(10)
    #   |> Task.async_stream(&MyApp.CsvsController.chunk_handler_fn/1)
    #   |> Stream.run


    def parse(%{location: location, days: days} = _item) do
        {:ok, location_record} = lookup_or_insert_location_record(location)
        Enum.each(days, fn(day_params) -> 
            create_or_update_date_record(location_record.id, day_params)
        end)
    end


    def create_days_keyword_list(date, value, type) do
        case type do
            :confirmed  -> ~w(date confirmed)a
            :death      -> ~w(date death)a
            :recovered  -> ~w(date recovered)a
        end
        |> Enum.zip([date, value])
    end



    def create_location_keyword_list([prov_state, country_region, lat, lng] = _row) do
        ~w(prov_state country_region lat lng)a
        |> Enum.zip([prov_state, country_region, lat, lng])
    end



    def parse_csv_header_into_dates(csv_header) do
         list_of_days = fn(csv_header_string) -> 
            String.split(csv_header_string, ",")
            |> Enum.drop(4) # remove the first 4 columns
            |> Enum.map(fn(item) -> 
                {:ok, result} = item 
                                |> String.replace("\r", "") 
                                |> String.replace("\n", "")
                                |> Timex.parse("{M}/{D}/{YY}")
                result
            end)
        end
        
        list_of_days.(csv_header)
    end

    

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


    @doc """
    inserting or looking up a location
    I need the id of the location. This will be used for the date_location record

    This will return a tuple, that will be used in another function
    {:ok, record}
    """
    def lookup_or_insert_location_record(params) do
        
        lookup_keywords = 
            Keyword.take(params, [:country_region, :lat, :lng])

        case Repo.get_by(Location, lookup_keywords) do
            nil     -> %Location{} |> Location.changeset(Map.new(params)) |> Repo.insert
            result  -> {:ok, result}
        end

    end

    # location_id = 93
    # params =  [date: ~N[2020-01-24 00:00:00], confirmed: 0]
    # 93, [date: ~N[2020-01-24 00:00:00], confirmed: 0]
    def create_or_update_date_record(location_id, params) do

        # %{
        #     params: [...],
        #     type_of_record: :confirmed,
        #     look_up_query: [location_id: "", date: "adasdasd"],
        #     csv_record_changed: true or false
        # }

        # we merged the `params` with location_id
        # [date: ~N[2020-01-24 00:00:00], confirmed: "0", location_id: 93]
        params =
            Keyword.put(params, :location_id, location_id)

        # `type_of_record` is dynamic
        # the CSV Timeseries will have data on "confirmed", or "recovered" or "death".
        # You should only be able to reference one of these
        # type_of_record will help build our SQL further down
        # [:death, :confirmed, :recovered]

        [type_of_record] = 
            Keyword.drop(params, [:location_id, :date]) 
            |> Keyword.keys # we remove the other keys as we don't need it

        # Do not need the :confirmed, :recovered or :death for the Query lookup
        lookup_keywords =
            Keyword.take(params, [:location_id, :date])

        # Only one record should be pulled if it exists. If your getting more then one you got an error
        # lookup_keywords is querying with keyword [location_id: 93, date: ...]

        case Repo.get_by(DateReport, lookup_keywords) do
            nil -> 
                params =  params |> Map.new
                %DateReport{} |> DateReport.changeset(params) |> Repo.insert()
            record -> 
                update_record_with_data(record, params, type_of_record)
        end
        
    end

    # Will return :no_update or a tuple {1, nil} which is what update_all does
    # --
    def update_record_with_data(record, params, type_of_record) do
        case Map.get(record, type_of_record) == Keyword.get(params, type_of_record) do
            true ->  :no_update
            false -> day_record_update_query(params, type_of_record) |> Repo.update_all([])
        end
    end


    @doc """  
    
    NOTE: https://groups.google.com/forum/#!msg/elixir-ecto/pFY1StOvvLE/Ll3K80O2AQAJ
    Schemas without primary keys cannot be updated or deleted with Repo.update/2 or Repo.delete/2 - ecto doesn’t 
    know how to build the constraint query - normally it uses the primary key. In order to update/delete a schema without primary key you need to use Repo.update_all or Repo.delete_all 

    DateReport does not have a primary_key
    for doing updates this makes it a bit more difficult to do updates
    as a result you must build up a query and pass it to `Repo.update_all([])` in order to update

    type_of_record = :confirmed
    params = [location_id: 1, date: ~N[2020-01-22 00:00:00], confirmed: "0"]  
    
    """  
    def day_record_update_query(params, type_of_record) do
        filters = Keyword.take(params, [:location_id, :date])
        case type_of_record do
            :confirmed -> from(p in DateReport, where: ^filters, update: [set: [confirmed: ^params[:confirmed]]])
            :recovered -> from(p in DateReport, where: ^filters, update: [set: [recovered: ^params[:recovered]]])
            :death     -> from(p in DateReport, where: ^filters, update: [set: [death: ^params[:death]]])
        end
    end
end