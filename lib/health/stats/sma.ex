defmodule Health.Stats.SMA do

    @doc """
    Defines a Simple Moving Average

    Returns `{:ok, sma}`, otherwise `{:error, reason}`.

    ## Examples

      iex> Health.Stats.SMA.sma([2, 2, 2, 2, 2, 2, 2, 20, 62, 155, 229, 322, 453, 655])
      {:ok,
        [
           %{avg: 25.1, input: [2, 2, 2, 2, 2, 2, 2, 20, 62, 155], period: 10}, 
           %{avg: 47.8, input: [2, 2, 2, 2, 2, 2, 20, 62, 155, 229], period: 10}, 
           %{avg: 79.8, input: [2, 2, 2, 2, 2, 20, 62, 155, 229, 322], period: 10}, 
           %{avg: 124.9, input: [2, 2, 2, 2, 20, 62, 155, 229, 322, 453], period: 10},
           %{avg: 190.2, input: [2, 2, 2, 20, 62, 155, 229, 322, 453, 655], period: 10}
        ]}

      iex> Health.Stats.SMA.sma([1])
      {:ok, [%{avg: 1.0, input: [1]}]}

      iex> Health.Stats.SMA.sma([])
      {:error, :no_data}

    ## Source
    Source: https://school.stockcharts.com/doku.php?id=technical_indicators:moving_averages
    
    """
    def sma([]), do: {:error, :no_data}
    def sma(list, period \\ 10) do
      result = 
        Enum.chunk_every(list, period, 1, :discard)
        |> Enum.map(fn(list) -> 
          %{input: list, avg: sum_and_average(list), period: period}
        end)
      {:ok, result}
    end

    defp sum_and_average(list) do
      Enum.sum(list) / length(list)
      |> Float.round(3)
    end

end