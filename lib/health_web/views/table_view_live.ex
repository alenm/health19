defmodule LiveFooWeb.TableViewLive do
    use Phoenix.LiveView

    def render(assigns) do
      case assigns.type_of_view do
          "list"  -> list_view(assigns)
          "table" -> table_view(assigns)
      end
    end

    def table_view(assigns) do
        ~L"""
        <div class="flex items-center justify-center mv4">
          <div class="hk-button-group">
            <button type="button" phx-click="toggle_view" class="hk-button--secondary" id="my_btn">List</button>
            <button type="button" class="hk-button--primary">Table</button>
          </div>
        </div>
        <%= Phoenix.View.render(HealthWeb.RegionsView, "_region_table.html", data: assigns.data, duration: assigns.duration, type_of_view: "table") %>
        """
    end

    def list_view(assigns) do
        ~L"""
        <div class="flex items-center justify-center mv4">
          <div class="hk-button-group">
            <button type="button" class="hk-button--primary">List</button>
            <button type="button" phx-click="toggle_view" id="my_btn" class="hk-button--secondary">Table</button>
          </div>
        </div>
        <%= Phoenix.View.render(HealthWeb.RegionsView, "_region_list.html", data: assigns.data, duration: assigns.duration, type_of_view: "list") %>
        """
    end

  
    def mount(_params, %{"data" => data, "duration" => duration, "type_of_view" => type} = _session, socket) do
      {:ok, assign(socket, data: data, duration: duration, type_of_view: type)}
    end


    def handle_event("toggle_view", _value, socket) do
        case socket.assigns.type_of_view do
            "list" ->  
              {:noreply, assign(socket, type_of_view: "table")}
            "table" -> 
              {:noreply, assign(socket, type_of_view: "list")}
        end
      end


  end