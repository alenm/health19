defmodule Health.Location do
    use Ecto.Schema
    import Ecto.Changeset
    import Ecto.Query
    alias Health.Location
    alias Health.Repo

    schema "locations" do
        # MY OWN LABEL SYSTEM  ------------------------------------------
        # These are fields that I want to keep track of.
        # I fill in the details by running Parser.Scrub.start
        field :iso_code,              :string
        field :label_city,            :string
        field :label_prov_state,      :string
        field :label_country_region,  :string
        field :special_note,          :string
        field :continent,             :string
        field :continent_iso_code,    :string
        # FROM THE CSV  ------------------------------------------
        # These are the original fields and will maintain them
        field :prov_state, :string
        field :country_region, :string
        field :lng, :float
        field :lat, :float

        has_many :date_reports, Health.DateReport
        #has_many :tally_reports, Health.TallyReport
        has_many :date_report_lag_stats, Health.DateReportLagStats
    end

    @attrs ~w(lng lat prov_state country_region)a
    @label_attrs ~w(iso_code label_city label_prov_state label_country_region special_note continent continent_iso_code)a

    def changeset(%Health.Location{} = location, attrs) do
        location
        |> cast(attrs, @attrs ++ @label_attrs)
        |> validate_required([:lng, :lat, :country_region])
    end


    # --------------------------------
    # Base Queries
    # --------------------------------


    def by_continent_iso(iso_code) do
        like = "#{iso_code}%"
        from l in Location, select: l, where: like(l.continent_iso_code, ^like), order_by: [asc: l.continent_iso_code]
    end

    def by_iso(iso_code) do
        like = "#{iso_code}%"
        from l in Location, select: l, where: like(l.iso_code, ^like), order_by: [asc: l.iso_code]
    end

    def by_city(city) do
        from l in Location, select: l, where: l.label_city == ^city
    end

    def by_state(state) do
        from l in Location, select: l, where: l.label_prov_state == ^state
    end

    def by_region(place) do
        from l in Location, select: l, where: l.country_region == ^place, order_by: [asc: l.label_prov_state]
    end

    def by_continent(name) do
        found = Enum.find(continents(), fn(item)-> item.continent == name end)
        from l in Location, select: l, where: l.continent == ^found.continent
    end

    @continents [{"Asia","as"}, {"Africa","af"}, {"Oceania","oc"}, {"Europe", "eu"}, {"North America","na"}, {"South America", "sa"}]

    def continents do
        Enum.map(@continents, fn({name, iso}) -> %{continent: name, continent_iso_code: iso} end)        
    end


    # --------------------------------
    # Region Queries
    # --------------------------------

    def regions do
        from(location in Location,
        distinct: location.label_country_region, 
        select: map(location, [:iso_code, :label_city, :label_prov_state, :label_country_region, :continent, :continent_iso_code]),
        order_by: [asc: :iso_code])
        |> Repo.all
        |> Enum.map(fn(item) -> 
            Map.put(item, :iso_code, String.slice(item.iso_code, 0..1)) # we only need the first two letters of the iso code. This makes it easier for grouping.
        end)
    end

    def regions_grouped do
        the_regions = regions()
        Enum.map(continents(), fn(%{continent: name, continent_iso_code: _iso} = item) -> 
            item |> Map.put_new(:regions, region_codes_by_continent_name(the_regions, name))
        end)
    end

    def regions_grouped_by(%{continent_iso_code: iso_code}) do
        by_continent_iso(iso_code)
        |> regions_grouping
    end

    def regions_grouped_by(%{continent: continent_name}) do
        by_continent(continent_name)
        |> regions_grouping
    end

    def regions_grouped_by(%{label_country_region: name}) do
        by_region(name)
        |> regions_grouping
        |> List.first
        |> case  do
            nil     -> {:not_found, "Check your spelling"}
            result  ->  Map.put_new(result, :label_country_region, name)
        end
    end

    def regions_grouped_by(%{iso_code: iso_code}) do
        String.slice(iso_code, 0..1) # we only want to look up by the first two characters
        |> by_iso()
        |> regions_grouping
        |> List.first
    end


    # --------------------------------
    # ISO Code Queries
    # --------------------------------

    def iso_codes do
        from(location in Location, 
        select: map(location, [:iso_code, :label_prov_state, :label_country_region]), 
        order_by: [asc: :iso_code])
        |> Repo.all
    end


    def iso_codes_grouped_by_continent do
        the_regions = regions()
        Enum.map(@continents, fn({continent, continent_iso}) -> 
            %{
                continent: continent,
                continent_iso_code: continent_iso,
                iso_codes: 
                Enum.filter(the_regions, fn(region) -> region.continent == continent end) 
                |> Enum.map(fn(item) -> {item.iso_code, item.label_country_region} end)
            }
        end)
    end


    def iso_codes_grouped_by(%{continent: continent_name}) do
        iso_codes_grouped_by_continent()
        |>Enum.find(fn(locations) -> locations.continent == continent_name end)
        |> case do
            nil     -> {:not_found, "Not found. These are the available continent names #{continent_names()}"}
            result  -> {:ok, result}
        end
    end


    def iso_codes_grouped_by(%{continent_iso_code: continent_iso}) do
        iso_codes_grouped_by_continent()
        |>Enum.find(fn(locations) -> locations.continent_iso_code == continent_iso end)
        |> case do
            nil     -> {:not_found, "Not found. These are the available continent iso codes #{continent_iso_codes()}"}
            result  -> {:ok, result}
        end
    end



    # --------------------------------
    # ISO Code Queries
    # --------------------------------


    defp regions_grouping(results) do
        results = 
            results
            |> Repo.all
            |> Enum.group_by(fn(item) -> item.continent end)

        continents = 
            Map.keys(results)

        Enum.map(continents, fn(key) -> 
            %{}
            |> Map.put_new(:continent, key)
            |> Map.put_new(:regions, region_codes_by_continent_name(Map.get(results, key), key))
        end) 
    end


    defp region_codes_by_continent_name(regions, continent_name) do
        Enum.filter(regions, fn(region) -> region.continent == continent_name end) 
        |> Enum.map(fn(item) -> Map.take(item, [:label_country_region, :iso_code]) end)
    end


    defp continent_names() do
        Enum.map(@continents, fn({name, _}) ->  "'#{name}''" end) |> Enum.join(", ")
    end


    defp continent_iso_codes() do
        Enum.map(@continents, fn({name, iso}) ->  "'#{iso}' = '#{name}'" end) |> Enum.join(", ")
    end


end