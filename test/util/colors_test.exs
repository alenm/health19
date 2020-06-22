defmodule Health.Util.ColorsTest do
    use Health.DataCase
  
    alias Health.Util.Colors

    describe "Colors" do

    @numbers     [0, 9, 49, 499, 999, 9999, 99999,  999999]
    @colors      ["#fffcef","#ffeda0","#fed976","#feb24c","#fd8d3c","#fc4e2a","#e31a1c","#b10026"]
    @font_colors ["#CCC", "#000000", "#000000", "#000000", "#000000", "#FFF", "#FFF", "#FFF"]
    
      test "all_colors" do
          a = Colors.all_colors()
          assert 8 == length(a), "Colros need to be counted"
      end
       
      test "bg color schemes" do
        colors = Colors.all_colors |> Enum.map(fn(item) -> item.bg_color end)
        assert 8 == length colors
        assert @colors == colors
      end

      test "font color schemes" do
          colors = Colors.all_colors |> Enum.map(fn(item) -> item.font_color end)
          assert 8 == length colors
          assert @font_colors == colors
      end

      test "get_bg_color/1 returns a bg color" do
          bg_colors = 
                @numbers
                |> Enum.map(fn(item) -> 
                    Colors.get_bg_color(item)
                end)
          assert @colors ==  bg_colors
      end

      test "get_font_color/1 returns a font_color" do
        font_colors = 
              @numbers
              |> Enum.map(fn(item) -> 
                  Colors.get_font_color(item)
              end)
        assert @font_colors ==  font_colors
    end

    end



end