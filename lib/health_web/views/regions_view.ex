defmodule HealthWeb.RegionsView do
    use HealthWeb, :view
    alias Health.Util.Formatter


    def title("index.html", _assigns) do
     "Regions"
    end

    @doc """
    Returns continent
    """
    def title("show.html", assigns) do
      assigns.data 
      |> List.first 
      |> Map.get(:location) 
      |> Map.get(:continent)
    end

    @doc """
    Returns label_country_region
    """
    def title("show_region.html", assigns) do
      assigns.data 
      |> List.first 
      |> Map.get(:location)
      |> Map.get(:label_country_region)
    end
 
    def tally_count(value) do
      case value do
        0     -> empty_row()
        _count -> count_row(value)
      end
    end

  
    def empty_row() do
      ~E"""
      <td class="bg-white light-gray pa1">0&nbsp;&nbsp;&nbsp;</td>
      """
    end

    def count_row(value) do
      ~E"""
      <td class="b bg-lightest-silver pa1"><%= Formatter.format_number(value) %> &nbsp;&nbsp;&nbsp;</td>
      """
    end

    def iso_row(item, conn) do
      link to: Routes.regions_path(conn, :show, conn.params["continent_iso"], String.downcase(item.iso_code)), title: "See reports from this location", class: "gray no link dim black" do
        ~E"""
        <%= item.label_prov_state %>
        """
      end
    end


    def render_world_tally_count(details) do
      [
        {:confirmed, "Confirmed"}, 
        {:recovered, "Recovered"}, 
        {:death, "Death"}
      ]
      |> Enum.map(fn({key,title}) -> 
        {Map.get(details, key), title} |> world_tally_box()
       end)
      |> render_world_tally_html
    end

    
    def world_tally_box({number, title}) do
      ~E"""
      <div class="ma2 flex-1 pa1 pl2 bb b--light-gray bg-gradient-extra-light-gray">
      <h1 class="f3 lh-title dark-gray"><%= Formatter.format_number(number) %>&nbsp;&nbsp;<%= title %></h1>
      </div>
      """
    end


    def render_world_tally_html(html) do
      ~E"""
      <div class="bg-white w-100 flex mt3 fade-in">
      <%= html %>
      </div>
      """
    end


    def get_total_table_count(data) do
      [summarize_total(data)]
    end

    
    defp summarize_total(data) do
      keys = [:confirmed, :recovered, :death]
      rows = Enum.map(keys, fn(key) -> sumitup(data, key) end)
      Enum.zip(keys, rows)
      |> Map.new 
    end

    def sumitup(data, key) do
      Enum.map(data, fn(item) -> Map.get(item.latest_report_sum, key) end) 
      |> Enum.sum 
      |> Formatter.format_number
    end

    def img_iso_flag(iso_code, class_style \\ "mr1 v-mid ba b--light-gray")
    def img_iso_flag("", _class_style), do: img_tag("/images/flag/unknown.png", class: "mr1 v-mid ba b--light-gray")
    def img_iso_flag(nil, _class_style), do: img_tag("/images/flag/unknown.png", class: "mr1 v-mid ba b--light-gray")
    def img_iso_flag(iso_code, class_style) do
      image = String.slice(iso_code, 0..1) <> ".png"
      f = "/images/flag/#{image}"
      img_tag(f, class: class_style, width: "20")
    end



  def get_date_range_for_table_header(data) do
      Enum.at(data, 1)
      |> Map.get(:new_confirmed_cases)
      |> Map.get(:duration)
      |> Map.take([:start, :end])
      |> generate_html_template()
  end

  def generate_html_template(%{start: start_date, end: end_date } = _map) do
    ~E"""
    <span class="fr fw5"><%= Timex.format!(start_date, "%b %d", :strftime) %> &#8594; <%= Timex.format!(end_date, "%b %d", :strftime) %></span>
    """
  end

  def duration_label(%{reports_duration: %{start: start_date, end_date: end_date, days_ago: _days_ago}} = _map) do
    ~E"""
    <span class="pl2 fw5">From <%= Timex.format!(start_date, "%b %d", :strftime) %> thru <%= Timex.format!(end_date, "%b %d", :strftime) %></span>
    """
  end

end
