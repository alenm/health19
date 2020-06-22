defmodule Health.Stats.SMATest do
    use Health.DataCase
  
    alias Health.Stats.SMA

    defmodule Fixtures do
        def numbers do
            [2, 2, 2, 2, 2, 2, 2, 20, 62, 155, 229, 322, 453, 655]
        end
    
        def numbers_sma do
            [
                %{avg: 25.1, input: [2, 2, 2, 2, 2, 2, 2, 20, 62, 155], period: 10}, 
                %{avg: 47.8, input: [2, 2, 2, 2, 2, 2, 20, 62, 155, 229], period: 10}, 
                %{avg: 79.8, input: [2, 2, 2, 2, 2, 20, 62, 155, 229, 322], period: 10}, 
                %{avg: 124.9, input: [2, 2, 2, 2, 20, 62, 155, 229, 322, 453], period: 10},
                %{avg: 190.2, input: [2, 2, 2, 20, 62, 155, 229, 322, 453, 655], period: 10}
            ]
        end

        def numbers_sma_4_day_period do
            [
                %{avg: 2.0, input: [2, 2, 2, 2], period: 4}, 
                %{avg: 2.0, input: [2, 2, 2, 2], period: 4}, 
                %{avg: 2.0, input: [2, 2, 2, 2], period: 4}, 
                %{avg: 2.0, input: [2, 2, 2, 2], period: 4}, 
                %{avg: 6.5, input: [2, 2, 2, 20], period: 4}, 
                %{avg: 21.5, input: [2, 2, 20, 62], period: 4}, 
                %{avg: 59.75, input: [2, 20, 62, 155], period: 4}, 
                %{avg: 116.5, input: [20, 62, 155, 229], period: 4}, 
                %{avg: 192.0, input: [62, 155, 229, 322], period: 4}, 
                %{avg: 289.75, input: [155, 229, 322, 453], period: 4}, 
                %{avg: 414.75, input: [229, 322, 453, 655], period: 4}
            ]
        end
      end

    describe "Simple Moving Average" do

      test "sma/1 with default 10 day period" do
        assert SMA.sma(Fixtures.numbers) == {:ok, Fixtures.numbers_sma}
        assert SMA.sma([]) === {:error, :no_data}
      end

      test "sma/2 with 4 day moving average" do
        assert SMA.sma(Fixtures.numbers, 4) == {:ok, Fixtures.numbers_sma_4_day_period}
        assert SMA.sma([]) === {:error, :no_data}
      end
      
    end

end