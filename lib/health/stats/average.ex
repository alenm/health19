defmodule Health.Stats.Average do
    
    @doc """
    Gets the mean of a list.

    Returns `{:ok, mean}`, otherwise `{:error, reason}`.

    ## Examples

      iex> Health.Stats.Average.mean([1, 2, 3, 4])
      {:ok, 2.5}

      iex> Health.Stats.Average.mean([1])
      {:ok, 1.0}

      iex> Health.Stats.Average.mean([])
      {:error, :no_data}

    ## Source
    Source: http://mathworld.wolfram.com/ArithmeticMean.html  

    """
    def mean([]), do: {:error, :no_data}
    def mean(data), do: {:ok, Enum.sum(data) / length(data)}

    @doc """
    Gets the median of a list.

    Returns `{:ok, median}`, otherwise `{:error, reason}`.

    ## Examples

      iex> Health.Stats.Average.median([1,4,2,5,0])
      {:ok, 2.0}

      iex> Health.Stats.Average.median([10,40,20,50])
      {:ok, 30}

      iex> Health.Stats.Average.median([1])
      {:ok, 1.0}

      iex> Health.Stats.Average.median([])
      {:error, :no_data}

    ## Source

     https://www.khanacademy.org/math/statistics-probability/summarizing-quantitative-data/mean-median-basics/a/mean-median-and-mode-review

    """
    def median([]), do: {:error, :no_data}
    def median(data) do
      midpoint =
        Enum.sort(data)
        |> length
        |> Integer.floor_div(2)
  
      # 0 is even, 1 is odd
      case data |> length |> rem(2) do
        0 ->
          {_, [med1, med2 | _]} = Enum.split(data, midpoint - 1)
          {:ok, (med1 + med2) / 2}
        1 ->
          {_, [median | _]} = Enum.split(data, midpoint)
          {:ok, median / 1}
      end
    end

    @doc """
    Gets the midrange of a list.

    Returns `{:ok, midrange}`, otherwise `{:error, reason}`.

    ## Examples

      iex> Health.Stats.Average.midrange([1, 2, 3, 4, 5])
      {:ok, 3.0}

      iex> Health.Stats.Average.midrange([1, 2, 3, 4])
      {:ok, 2.5}

      iex> Health.Stats.Average.midrange([1])
      {:ok, 1.0}

      iex> Health.Stats.Average.midrange([])
      {:error, :no_data}

    """
    def midrange([]), do: {:error, :no_data}
    def midrange(data) do
      max = data |> Enum.max
      min = data |> Enum.min
  
      {:ok, (max + min) / 2}
    end

    @doc """
    Gets the most frequently occuring value in a list.

    Returns `{:ok, mode}`, otherwise `{:error, reason}`.

    ## Examples

      iex> Health.Stats.Average.mode([1, 2, 3, 4, 5])
      {:ok, [1, 2, 3, 4, 5]}

      iex> Health.Stats.Average.mode([1, 2, 3, 4, 2])
      {:ok, 2}

      iex> Health.Stats.Average.mode([1])
      {:ok, 1}

      iex> Health.Stats.Average.mode([])
      {:error, :no_data}

    """
    def mode([]), do: {:error, :no_data}
    def mode(data) do
      case occur(data) do
        {:ok, occur} -> {:ok, map_max(occur)}
        {:error, reason} -> {:error, reason}
      end
    end

    defp occur([]), do: {:error, :no_data}
    defp occur(data) do
        result = Enum.reduce(data, %{}, fn(tag, acc) ->
         Map.update(acc, tag, 1, &(&1 + 1))
        end)

        {:ok, result}
    end

    defp map_max(map) do
        max = map
        |> Map.values
        |> Enum.max
    
        # Create array of maximums
        # Add key to maximums array
        maxes = Enum.reduce(map, [], fn({key, value}, acc) ->
          case value do
            ^max -> [key | acc]
            _ -> acc
          end
        end)
    
        # Support multiple maximums %{a: 3, b: 3} => [:a, :b]
        # Or single maximum %{a: 3, b: 2} => [:a]
        case maxes do
          [n] -> n
          [_ | _] = array -> Enum.reverse(array)
        end
    end


end