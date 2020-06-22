defmodule Health.Util.Formatter do

    def format_number(number) do
        number
        |> to_string
        |> String.replace(~r/\d+(?=\.)|\A\d+\z/, fn(int) ->
          int
          |> String.graphemes
          |> Enum.reverse
          |> Enum.chunk_every(3, 3, [])
          |> Enum.join(",")
          |> String.reverse
        end)
      end

      
    defmodule ListSum do
      def sum(list1, list2, total \\ [])
    
      def sum([], [], total) do
        Enum.reverse(total)
      end
    
      def sum([h1 | t1], [], total) do
        sum(t1, [], [h1 | total])
      end
    
      def sum([], [h2 | t2], total) do
        sum([], t2, [h2 | total])
      end
    
      def sum([h1 | t1], [h2 | t2], total) do
        sum(t1, t2, [h1 + h2 | total])
      end
    end



end