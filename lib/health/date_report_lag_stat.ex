defmodule Health.DateReportLagStats do
    use Ecto.Schema

    @primary_key false

    # This is materialized view with Postgres

    schema "date_report_lag_stats" do
        belongs_to :location, Health.Location
        field :date, :date
        # CONFIRMED
        field :confirmed, :integer, default: 0
        field :confirmed_yesterday, :integer, default: 0
        field :confirmed_daily_delta, :integer
        field :confirmed_daily_delta_pct, :decimal
        # RECOVERED
        field :recovered, :integer, default: 0
        field :recovered_yesterday, :integer, default: 0
        field :recovered_daily_delta, :integer
        field :recovered_daily_delta_pct, :decimal
        # DEATH
        field :death, :integer, default: 0
        field :death_yesterday, :integer, default: 0
        field :death_daily_delta, :integer
        field :death_daily_delta_pct, :decimal
    end



end

