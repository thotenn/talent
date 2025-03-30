defmodule Talent.Repo.Migrations.CreatePeopleInfo do
  use Ecto.Migration

  def change do
    create table(:people_info) do
      add :full_name, :string
      add :short_name, :string
      add :phone, :string
      add :identity_number, :string
      add :birth_date, :date
      add :gender, :string
      add :extra_data, :text

      timestamps(type: :utc_datetime)
    end
  end
end
