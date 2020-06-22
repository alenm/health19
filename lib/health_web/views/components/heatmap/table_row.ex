defmodule HealthWeb.Components.HeatmapCalendarView.TableRow do
    
    alias Health.Util.{
        Colors,
        Formatter
    }

    defstruct [:location, :dates]
    
    def new(location, dates) do
        %__MODULE__{location: location, dates: parse_daily_delta_records(dates)}
    end

    def parse_daily_delta_records(records) do
        Enum.map(records, fn(item) -> 
            %{}
            |> Map.put_new(:value, Formatter.format_number(item.daily_delta))
            |> Map.merge(Colors.get_color_scheme_by(item.daily_delta)) 
        end)
    end

end

