defmodule HealthWeb.Components.GraphlineView do
    use HealthWeb, :view

    alias HealthWeb.Components.GraphViewModel 
    alias HealthWeb.Components.Graph
    alias Health.Reports.MergeReports

    def location_label(obj) do
      [
        Map.get(obj, :continent),
        Map.get(obj, :label_country_region),
        Map.get(obj, :label_prov_state),
        Map.get(obj, :label_city),
        Map.get(obj, :special_note)
      ]
      |> Enum.reject(&is_nil/1) 
      |> Enum.intersperse(" / ")
      |> Enum.join
    end

    @doc """
    Renders a list of Graphs. This is then used in the template to render.
    iex> render_list_of_sparklines(obj)

    [%Graph{}, %Graph{}, %Graph{}]

    """
    # def render_results(results) when is_list(results) do
    #   Enum.map(results, fn(item)-> 
    #     GraphViewModel.changeset(%GraphViewModel{}, item)
    #   end)
    #   |> render_list_of_sparklines
    # end

    def render_results(results) when is_list(results) do
      MergeReports.from_reports(results)
      |> render_results()
    end


    def render_results(results) do
      GraphViewModel.changeset(%GraphViewModel{}, results)
      |> render_list_of_sparklines
    end

    defp render_list_of_sparklines(list) when is_list(list) do
      Enum.map(list, fn(item) -> 
        render_sparkline(item)
      end)
    end


    defp render_list_of_sparklines(obj) do
      [render_sparkline(obj)]
    end


    defp render_sparkline(obj) do
      keys = ~w(confirmed recovered death)a
      Enum.map(keys, fn(key) -> 
         Graph.build(key, obj)
       end)
    end


    def render_headline(list) do
      List.first(list)
      |> Map.get(:params)
    end
  

    def create_classname_for_graph(css_class_var_name, css_classname) do
      "#{css_class_var_name} #{css_classname}"
    end


end