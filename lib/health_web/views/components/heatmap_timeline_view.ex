defmodule HealthWeb.Components.HeatmapTimelineView do
    use HealthWeb, :view

    alias Health.Util.Colors
    #TODO Need to create a dynamic width for the strip

    defmodule Square do

        alias Health.Util.Colors

        @width  8
        @height 12
        @stroke_color "#eceff4"

        defstruct [:style, :height, :width, :x, :y, :count]
    
        def build(number, index) do
            formatted_attrs = %{
              style: get_style(number),
              height: @height,
              width:  @width,
              x: @width * index,
              y: 0,
              count: number
            }
            struct(__MODULE__, formatted_attrs)
        end

        def get_style(number) do
            [get_stroke(), get_fill(number)]
            |> Enum.join(" ")
        end

        defp get_stroke do
            "stroke:#{@stroke_color}; stroke-width: 0.5;"
        end

        defp get_fill(number) do
            "fill: #{Colors.get_bg_color(number)};"
        end

    end

   
    def render_legend do
        [{1,"10"}, {10,"50"}, {100,"100"}, {500,"500"}, {1000,"1,000"}, {10000,"10,000"}]
        |> Enum.map(fn({num, label}) -> 
            {label,  Colors.get_bg_color(num)}
        end)
    end


    @doc """
    Pass in the `confirmed` data set and it get converted into an array of integers
    that the graph will need to build the timeline.
    """
    def render_time_line_squares(%{confirmed: list_of_data} = _obj) do
        results = 
            Enum.map(list_of_data, fn(item) -> 
                item.daily_delta
            end)
        render_time_line_squares(%{new_confirmed_cases: results})
    end


    def render_time_line_squares(%{new_confirmed_cases: data} = _obj) do
        data
        |> Enum.with_index()
        |> Enum.map(fn({num, index}) -> 
            Square.build(num, index)
        end)
    end


end
