defmodule Health.Stats.AverageTest do
    use Health.DataCase
  
    alias Health.Stats.Average

    defmodule Fixtures do
        def numbers do
          [
            189, 177,  253, 64, 8, 617, 320,  26, 24, 53,
            46, 30, 100, 48, 34, 69, 40, 44, 66, 89
          ]
        end
    
        def numbers_mean, do: 2297 / 20
        def numbers_median, do: (53 + 46) / 2
        def numbers_mode, do: [8, 24, 26, 30, 34, 40, 44, 46, 48, 53, 64, 66, 69, 89, 100, 177, 189, 253, 320, 617]
        def numbers_midrange, do: (8 + 617) / 2
      end

    describe "average" do
  
      test "mean/1" do
        assert Average.mean(Fixtures.numbers) == {:ok, Fixtures.numbers_mean}
        assert Average.mean([]) === {:error, :no_data}
        assert Average.mean([42]) == {:ok, 42}
      end

      test "median/1" do
        assert Average.median(Fixtures.numbers) == {:ok, Fixtures.numbers_median}
        assert Average.median([]) === {:error, :no_data}
        assert Average.median([42]) == {:ok, 42}
      end

      test "midrange/1" do
        assert Average.midrange(Fixtures.numbers) == {:ok, Fixtures.numbers_midrange}
        assert Average.midrange([]) === {:error, :no_data}
        assert Average.midrange([42]) == {:ok, 42}
      end

      test "mode/1" do
        assert Average.mode(Fixtures.numbers) == {:ok, Fixtures.numbers_mode}
        assert Average.mode([]) === {:error, :no_data}
        assert Average.mode([42]) == {:ok, 42}
      end

    end

end
