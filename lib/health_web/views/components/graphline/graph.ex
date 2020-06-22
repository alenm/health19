defmodule HealthWeb.Components.Graph do
    use HealthWeb, :view
    alias Health.Util.Random
    alias Health.Util.Formatter
        @doc """
        This module `Graph` is used to build out the `SparklineView`.
        The `obj` is from `Health.Measures.Sparkline.prepare_data/1`
        and is then passed into this module that will build the
        HTML, associated JS and other details

        iex> Graph.build(:confirmed, obj)

        """
        defstruct [:title, :end_count, :days_ago, :delta_count, :js_details, :type_of_report, :html_assets, :color_scheme, :params]
        @doc """
        Pass in the data and one of the report keys [:confirmed, :recovered, :death]
        iex> Graph.build(:confirmed, obj)

        """
        def build(key, obj) when key in [:confirmed, :recovered, :death] do
          formatted_attrs = %{
            title:  get_title(key),
            end_count: get_end_count(key, obj),
            days_ago: get_days_ago(obj),
            delta_count: get_delta_count(key, obj),
            js_details: get_data_for_js(key, obj.data),
            type_of_report: get_type_of_report(key),
            html_assets: create_var_names(key),
            color_scheme: get_color_scheme(key),
            params: get_params(obj)
          }
          struct(__MODULE__, formatted_attrs)
          # *NOTE: All new attributes must also appear in the `defstruct`. Did you add it there?
        end

        def build(key, _obj), do: params_error(key)
        def build(key), do: params_error(key)
        def params_error(_key), do: raise ArgumentError, "Must pass in one of the following keys `:confirmed, :recovered, :death` and an obj"

        
        def get_params(obj) do
          Map.get(obj, :params)
        end

        @doc """
        Returns the difference count of cases on the newest day
        """
        def get_end_count(key, obj) do
          Map.get(obj.stats, key) 
          |> Map.get(:end_count)
        end

        @doc """
        Returns the difference count of cases from the oldest day to the newest day
        Example: if oldest day the count is 10 and the newest dat the count is 100
        you would have had a delta count of 90
        """
        def get_delta_count(key, obj) do
          result = 
            Map.get(obj.stats, key) 
            |> Map.get(:delta_count)
            
          case result do
            0 -> "No change"
            n -> if n > 0, do: "↑ #{Formatter.format_number(n)}", else: "↓ #{Formatter.format_number(n)}"
          end
          
        end

        @doc """
        Returns the length of days this graph is reporting on
        """
        def get_days_ago(obj) do
          obj.duration.days_ago
        end

        @doc """
        Returns the string title based on the type of key report
        """
        def get_title(key) do
          case key do
             :confirmed -> "Confirmed"
             :recovered -> "Recovered"
             :death -> "Death"
             _ -> "Unknown"
          end
        end

        @doc """
        Get the chart color scheme. Stroke and fill color
        """
        def get_color_scheme(key) do
         results =
           case key do
            :confirmed -> ["blue", "rgba(0, 0, 255, .1)"]
            :recovered -> ["rgb(10, 155, 33)", "RGBA(36, 159, 73, 0.2)"]
            :death    ->  ["black", "rgba(88, 92, 80, 0.28)"]
          end
          Enum.zip(~w(stroke fill)a, results) 
          |> Map.new
        end

        @doc """
        Returns the data into a format is javascript friendly
        """
        def get_data_for_js(key, obj) do
          list = Map.get(obj, key)
           Enum.map(list, fn(item) -> 
             %{name: item.name, date: item.date, value: item.value, formatted_value: Formatter.format_number(item.value)}
           end)
           |> Jason.encode!
           |> raw
       end

        @doc """
        Returns report atom into a string
        """
       def get_type_of_report(key) do
          Atom.to_string(key)
       end

        @doc """
        Returns keys that deal with the structure and mapping of HTML
        with the JS. Each graph will get HTML template and `<script>` tags
        that will get rendered with it. These keys are used within the template.

        `:type_of_report` - Is a string name. For example 'confirmed' 
          This will be used to build out the `:css_class_var_name` later.

        `:js_var_name` - A random string like `DqzKE2yn`. This will be used 
        to construct the `:css_class_var_name` later.

        `:css_class_var_name` - This is a unique name .class name that is
          referenced in the template. Such as `confirmed-DqzKE2yn`

        `:spark_line_selector` - This is the query selector that is used to
        reference the HTML in the template and it goes with the JS

        sparkline.sparkline(document.querySelector(".<%= `confirmed-DqzKE2yn` %>"), <%= DqzKE2yn %>, options);

        """
       def create_var_names(key) do
        type_of_report = Atom.to_string(key)
        r =  Random.string()
        %{}
        |> Map.put_new(:type_of_report, type_of_report)
        |> Map.put_new(:js_var_name, r)
        |> Map.put_new(:css_class_var_name, "#{type_of_report}-#{r}")
        |> sparkline_selector
       end

       @doc """
       Returns the document selector that each graph requires
       """
       def sparkline_selector(%{css_class_var_name: css_class, js_var_name: js_var_name} = map) do
        map
        |> Map.put_new(:spark_line_selector, sparkline_selector("#{css_class}", js_var_name))
      end
  
      def sparkline_selector(class, js_var_name) do
        ~E"""
        sparkline.sparkline(document.querySelector(".<%= class %>"), <%= js_var_name %>, options);
        """
      end
       
end

