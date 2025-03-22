defmodule Talent.Repo.Migrations.CreateDashboardInfos do
  use Ecto.Migration

  def change do
    create table(:dashboard_infos) do

      timestamps(type: :utc_datetime)
    end
  end
end
