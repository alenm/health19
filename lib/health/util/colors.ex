defmodule Health.Util.Colors do

    @moduledoc """
    Common colors schemes for reporting
    """

    @doc """
    This will return a color scheme based on a value
    iex > get_color_scheme_by(1000)
    %{bg_color: "#bcbddc", font_color: "#000000"}
    """
    def get_color_scheme_by(value) do
        get_color_by_heatmap_scale(value)
    end

    @doc """
    Will return a map of a `bg_color` and `font_color` based on input of integer

    iex > get_color_by_heatmap_scale(1000)
    %{bg_color: "#bcbddc", font_color: "#000000"}

    Colors come from  https://colorbrewer2.org/#type=sequential&scheme=BuGn&n=8
    """
    @colors     ["#fffcef","#ffeda0","#fed976","#feb24c","#fd8d3c","#fc4e2a","#e31a1c","#b10026"]
    @font_colors ["#CCC", "#000000", "#000000", "#000000", "#000000", "#FFF", "#FFF", "#FFF"]
    
    def get_color_by_heatmap_scale(n) when n == 0, do: get_color_scheme(0)
    def get_color_by_heatmap_scale(n) when n in 1..9, do: get_color_scheme(1)
    def get_color_by_heatmap_scale(n) when n in 10..49, do: get_color_scheme(2)
    def get_color_by_heatmap_scale(n) when n in 50..499, do: get_color_scheme(3)
    def get_color_by_heatmap_scale(n) when n in 500..999, do: get_color_scheme(4)
    def get_color_by_heatmap_scale(n) when n in 1000..9999, do: get_color_scheme(5)
    def get_color_by_heatmap_scale(n) when n in 10000..99999, do: get_color_scheme(6)
    def get_color_by_heatmap_scale(n) when n in 100000..999999, do: get_color_scheme(7)
    def get_color_by_heatmap_scale(n) when n in 1000000..9999999, do: get_color_scheme(8)
    def get_color_by_heatmap_scale(n) when n in 10000000..99999999, do: get_color_scheme(8)
    def get_color_by_heatmap_scale(n) when (n < 0), do: get_color_scheme(0)
    def get_color_by_heatmap_scale(n) when is_nil(n), do: get_color_scheme(0)


    @doc """
    Returns all known color schemes
    """
    def all_colors() do
        Enum.zip(@colors, @font_colors)
        |> Enum.map(fn({color, font_color}) -> 
            %{
                bg_color: color,
                font_color: font_color
            }
        end)
    end
    
    def get_bg_color(number) do
        get_color_by_heatmap_scale(number) 
        |> Map.get(:bg_color)
    end

    def get_font_color(number) do
        get_color_by_heatmap_scale(number) 
        |> Map.get(:font_color)
    end

    defp get_color_scheme(index) do
        Enum.at(all_colors(), index)
    end
    

end