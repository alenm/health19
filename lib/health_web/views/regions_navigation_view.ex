defmodule HealthWeb.RegionsNavigationView do
  use HealthWeb, :view


  defmodule NavItem do
      defstruct [:controller, :label, :route, :is_active, :theme_color, :title]
    end
    
    def main_navigation(conn) do
        for navitem <- format_navitems(conn) do
          create_link(navitem)
        end
        |> html_template()
    end

    defp create_link(navitem) do
      if navitem.is_active do
        link(navitem.label, to: navitem.route, class: css_style()[:selected], title: navitem.title)
      else
        link(navitem.label, to: navitem.route, class: css_style()[:unselected], title: navitem.title)
      end
    end
    
    defp format_navitems(conn) do
      current = 
        current_path(conn)
        |> String.slice(0..10) # We just check for the first 11 characters for a match

      nav_items()
      |> Enum.map(fn(item) ->
        if item.route == current do
          %{item | is_active: true}
        else
          item
        end
      end)
    end
  
  
  defp current_path(conn) do
      conn.request_path
  end
    
  defp nav_items do
    [
      %NavItem{controller: "regions", label: "World", route: "/regions", is_active: false, title: "See home"},
      %NavItem{controller: "regions", label: "Asia", route: "/regions/as", is_active: false, title: "See by region"},
      %NavItem{controller: "regions", label: "Africa", route: "/regions/af", is_active: false, title: "See by regions"},
      %NavItem{controller: "regions", label: "Oceania", route: "/regions/oc", is_active: false, title: "See by region"},
      %NavItem{controller: "regions", label: "Europe", route: "/regions/eu", is_active: false, title: "See by region"},
      %NavItem{controller: "regions", label: "North America", route: "/regions/na", is_active: false, title: "See by region"},
      %NavItem{controller: "regions", label: "South America", route: "/regions/sa", is_active: false, title: "See by region"}
    ]
  end

  defp css_style do
    base = "f5"
    [
        selected: "#{base} hk-tabs__tab--active", 
        unselected: "#{base} rk-tabs__tab",
    ]
  end


  defp html_template(html) do
    ~E"""
    <div class="fixed w-100 bb b--light-gray bg-white">
    <div class="center mw9 ph3-ns">
    <nav class="pa3 pa4-ns f6 fw6">
    <%= html %>
    </nav>
    </div>
    </div>
    """
  end



    




end