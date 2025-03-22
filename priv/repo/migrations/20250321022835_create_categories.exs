defmodule Talent.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :description, :text
      add :max_points, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
