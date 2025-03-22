defmodule Talent.Repo.Migrations.CreateJudges do
  use Ecto.Migration

  def change do
    create table(:judges) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:judges, [:user_id])
  end
end
