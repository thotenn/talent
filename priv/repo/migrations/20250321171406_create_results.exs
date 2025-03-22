defmodule Talent.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :category_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
