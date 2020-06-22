defmodule HealthWeb.Components.HeatmapCalendarView do
    use HealthWeb, :view

    alias HealthWeb.Components.HeatmapCalendarView.{
        TableHeader,
        TableRow
    }

    # TODO: 
    # create error for when a struct that is no a LagStatReport is passed in

    @doc """
    Pass in a list of [%LagStatReport{}] and conn and it will return
    HTML of calendar heatmap
    """
    def parse_data_render_html(data, conn) do
        table_headers = 
            List.first(data) 
            |> Map.get(:confirmed)
            |> TableHeader.new()
            |> to_html()

        rows =
            Enum.map(data, fn(item) -> 
                TableRow.new(item.location, item.confirmed)
                |> to_html(conn)
            end)

        [table_headers, rows]
    end

    defp to_html(%TableHeader{prov: p, city: c, dates: records}) do
        ~E"""
            <div class="w-100 flex flex-auto bb bb b--silver fade-in b" id="my_table" data-user-view="table">
            <div class="h2 w2 mr1 ml1 bg-white flex-3 pa1"><%= p %></div>
            <div class="h2 w2 mr1 ml1 bg-white flex-3 pa1"><%= c %></div>
            <%= for record <- records do %>
                <div class="h2 w2 flex-1 pa1"><%= record %></div>
            <% end %>
            </div>
        """
    end

    defp to_html(%TableRow{location: location,  dates: records}, conn) do
        ~E"""
        <div class="w-100 flex flex-auto bb bb b--silver fade-in">
          <div class="h2 w2 mr1 ml1 bg-white flex-3 pa1 b"><%= link location.label_prov_state, to: Routes.regions_path(conn, :show, location.continent_iso_code, String.downcase(location.iso_code)), title: "See breakdown", class: "dark-gray no link dim b black" %></div>
            <div class="h2 w2 mr1 ml1 bg-white flex-3 pa1"><%= location.label_city %></div>
          <%= for %{value: count, bg_color: bg_color, font_color: font_color} <- records do %>
              <div class="h2 w2 flex-1 pa1 tc br b--white" style="background-color: <%= bg_color %>; color: <%= font_color %>"><%= count %></div>
          <% end %>
        </div>
        """
    end

end
