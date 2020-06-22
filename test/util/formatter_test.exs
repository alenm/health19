defmodule Health.Util.FormatterTest do
    use Health.DataCase
  
    alias Health.Util.Formatter


    describe "Formatter" do

        test "format_number/1 will add commas to integers from the thousands and greater" do
            assert "8,000,000" = Formatter.format_number(8000000)
            assert "800,000" = Formatter.format_number(800000)
            assert "80,000" = Formatter.format_number(80000)
            assert "8,000" = Formatter.format_number(8000)
            assert "800" = Formatter.format_number(800)
            assert "80" = Formatter.format_number(80)
            assert "8" = Formatter.format_number(8)
        end

    end



end