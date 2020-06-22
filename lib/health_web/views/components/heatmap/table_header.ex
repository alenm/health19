defmodule HealthWeb.Components.HeatmapCalendarView.TableHeader do
    defstruct [:prov, :city, :dates]

    def new(records) do
        %__MODULE__{prov: "Prov/State", city: "City", dates: parse_dates(records)}
    end

    def parse_dates(records) do
        Enum.map(records, fn(item) -> 
            Timex.format!(item.date, "%b %d", :strftime)
        end)
    end
end