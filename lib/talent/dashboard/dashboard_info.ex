defmodule Talent.Dashboard.DashboardInfo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dashboard_infos" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dashboard_info, attrs) do
    dashboard_info
    |> cast(attrs, [])
    |> validate_required([])
  end
end
