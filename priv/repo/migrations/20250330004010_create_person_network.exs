defmodule Talent.Repo.Migrations.CreatePersonNetwork do
  use Ecto.Migration

  def change do
    create table(:person_networks) do
      add :person_id, references(:people_info, on_delete: :delete_all), null: false
      add :network_id, references(:networks, on_delete: :delete_all), null: false
      add :username, :string, null: false
      add :url, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:person_networks, [:person_id])
    create index(:person_networks, [:network_id])
    create unique_index(:person_networks, [:person_id, :network_id, :url], name: :person_network_unique_index)
  end
end
