defmodule Talent.Repo.Migrations.CreateNetwork do
  use Ecto.Migration

  def change do
    create table(:networks) do
      add :name, :string, null: false
      add :base_url, :string, null: true
      add :description, :text, null: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:networks, [:name])
  end
end
