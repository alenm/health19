defmodule Health.Util.RandomTest do
    use Health.DataCase
  
    alias Health.Util.Random


    # This is needed for the JS graph where I need a random string for naming
    describe "Random generates a random string" do

        test "string/1 will return 8 character string" do
            assert 8 == Random.string() |> String.graphemes |> length
        end

    end



end