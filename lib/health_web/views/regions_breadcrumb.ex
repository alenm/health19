defmodule HealthWeb.RegionsBreadcrumbView do
  use HealthWeb, :view
  alias HealthWeb.RegionsView

  @doc """
      When you navigate to a page within regions you will have some keys available in that view.
      The breadcrumb looks for those keys and constructs the breadcrumb based on those keys.

      For example:
        • User navigations to `/reigons/na` then `%{continent: "North America", continent_iso_code: "NA"}`
        • User navigates to `/regions/na/ca` then `%{country_region: "Canada", country_iso_code: "CA", continent_iso_code: "NA"}`

      The user needs to pass in the @data from the controller within `/regions`

  """
  @keys  ~w(continent continent_iso_code label_country_region iso_code label_prov_state)a

  def breadcrumb(data, conn) when is_map(data) do
    Map.take(data, @keys)
    |> create_links(conn)
  end

  def breadcrumb(data, conn) when is_list(data) do
    list_of_prov_state =
      Enum.map(data, fn(item) -> item.location.label_prov_state end)
      |> Enum.uniq
      |> Enum.reject(&is_nil/1)
    case length(list_of_prov_state) do
      1 -> get_location_details(data) |> create_prov_links(conn) # means the viewer is looking at data on one prov_state
      _ -> get_location_details(data) |> create_links(conn)
    end
  end

  def get_location_details(data) do
    List.first(data)
      |> Map.get(:location)
      |> Map.take(@keys)
  end

  def create_prov_links(%{continent: continent_label, continent_iso_code: continent_iso_code, label_country_region: country_region, iso_code: iso_code, label_prov_state: label_prov_state}, conn) do
    continent = link continent_label, to: Routes.regions_path(conn, :show, String.downcase(continent_iso_code)), title: "See reports from this location", class: "gray no link dim black breadcrumb"
    country   = link country_region, to: Routes.regions_path(conn, :show, String.downcase(continent_iso_code), String.downcase(String.slice(iso_code, 0..1))), title: "See reports from this location breadcrumb", class: "gray no link dim black"
    country_flag = RegionsView.img_iso_flag(iso_code, "ml1 mr1 v-btm ba b--light-gray")
    Enum.intersperse([continent, country, [country_flag, label_prov_state]], " → ") # The arrow for the breadcrumb is within the css file .breadrcrumb
    |> breadcrumb_html
  end

  defp create_links(%{continent: continent_label, continent_iso_code: continent_iso_code, label_country_region: country_region, iso_code: iso_code}, conn) do
    continent = link continent_label, to: Routes.regions_path(conn, :show, String.downcase(continent_iso_code)), title: "See reports from this location", class: "gray no link dim black breadcrumb"
    country   = link country_region, to: Routes.regions_path(conn, :show, String.downcase(continent_iso_code), String.downcase(String.slice(iso_code, 0..1))), title: "See reports from this location breadcrumb", class: "gray no link dim black"
    country_flag = RegionsView.img_iso_flag(iso_code, "ml1 mr1 v-btm ba b--light-gray")
    Enum.intersperse([continent, [country_flag, country]], " → ") # The arrow for the breadcrumb is within the css file .breadrcrumb
    |> breadcrumb_html
  end

  defp create_links(%{continent: continent_label, continent_iso_code: continent_iso_code}, conn) do
    continent = link continent_label, to: Routes.regions_path(conn, :show, String.downcase(continent_iso_code)), title: "See reports from this location", class: "gray no link dim black breadcrumb"
    continent
    |> breadcrumb_html
  end

  def breadcrumb_html(html) do
    ~E"""
    <div class="w-100 flex bb b--light-gray mt4 pb2">
    <div class="w2 bg-white flex-1"><h1 class="f4 gray mv0 pl2"><%= html %></h1></div>
    <div class="w2 bg-white flex-1"><%= render HealthWeb.Components.HeatmapTimelineView, "legend.html" %></div>
    </div>
    """
  end



end