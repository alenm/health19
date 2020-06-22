defmodule HealthWeb.Components.GraphViewModel do

    import Ecto.Changeset
    use Ecto.Schema

    @primary_key false
  
    embedded_schema do
        field :data,                 :map
        field :duration,             :map
        field :params,               :map
        field :stats,                :map
    end

    @keys ~w(data duration params stats)a

    def changeset(%HealthWeb.Components.GraphViewModel{} = graph, params) do
        with {:ok, v_params} <- validate_params(params),
             {:ok, p_params} <- prepare_params(v_params) do

            graph
            |> cast(p_params, @keys)
            |> apply_changes
        end
    end

    defp validate_params(%Health.Reports.LagStatReport{} = obj), do: {:ok, obj}
    defp validate_params(%Health.Reports.GroupedLagStatReport{} = obj), do: {:ok, obj}
    defp validate_params(%Health.Reports.MergeReports{} = obj), do: {:ok, obj}
    defp validate_params(_term), do: raise "Invalid Struct. Must pass in a LagStatReport, GroupedLagStatReport or MergeReports struct."

    @doc """
    This builds up the params so it can be passed into the struct
    The `params` need to be some %Location{} struct that needs to
    be passed in.
    """
    def prepare_params(params) do
        result =
            %{}
            |> build_meta_params(params)
            |> build_duration(params)
            |> build_stats(params)
            |> build_data(params)
        {:ok, result}
    end

    @doc """
    Returns %{params: %{iso_code: "it"}}
    """
    def build_meta_params(map, params) do
        map
        |> Map.put_new(:params, Map.take(params.location, [:iso_code, :label_city, :label_country_region, :label_prov_state, :special_note]))
    end


    @doc """
    Returns %{duration: %{days_ago: 30, end: ~D[2020-02-27], start: ~D[2020-01-22]}}
    """
    def build_duration(map, params) do
        map
        |> Map.put_new(:duration, params.reports_duration)
    end


    @doc """
    This is used for labels within the graph to show counts
    Returns %{stats: %{confirmed: %{start_count: 0, end_count: 0, delta_count: 0}, death: %{..}, recovered: %{..}}
    """
    def build_stats(map, params) do
        map
        |> Map.put_new(:stats, build_stats(params))
    end

    def build_stats(params) do
        %{}
        |> Map.put_new(:confirmed, build_stats_for(params, :confirmed))
        |> Map.put_new(:recovered, build_stats_for(params, :recovered))
        |> Map.put_new(:death, build_stats_for(params, :death))
    end

    def build_stats_for(params, key) do
        data    = Map.get(params, key)
        start_c = List.first(data) |> Map.get(:current)
        end_c   = List.last(data) |> Map.get(:current)
        %{}
        |> Map.put_new(:start_count, start_c)
        |> Map.put_new(:end_count, end_c)
        |> Map.put_new(:delta_count, (end_c - start_c))
    end

    @doc """
    Return data information that is used for graphing
    """
    def build_data(map, params) do
        map
        |> Map.put_new(:data, build_data(params))
    end


    def build_data(params) do
        %{}
        |> Map.put_new(:confirmed, build_data_for(params, :confirmed))
        |> Map.put_new(:recovered, build_data_for(params, :recovered))
        |> Map.put_new(:death, build_data_for(params, :death))
    end


    def build_data_for(params, key) do
        case key do
            :confirmed -> Enum.map(params.confirmed, fn(item) -> get_prep_data_for_graph(item, "Confirmed") end)
            :recovered -> Enum.map(params.recovered, fn(item) -> get_prep_data_for_graph(item, "Recovered") end)
            :death     -> Enum.map(params.death, fn(item) -> get_prep_data_for_graph(item, "Death") end)
        end
    end

    def get_prep_data_for_graph(item, name) do
        %{}
        |> Map.put_new(:name, name)
        |> Map.put_new(:date, Map.get(item, :date))
        |> Map.put_new(:count_change, Map.get(item, :daily_delta))
        |> Map.put_new(:value, Map.get(item, :current))
    end


end


