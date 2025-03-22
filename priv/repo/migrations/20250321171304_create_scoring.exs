defmodule Talent.Repo.Migrations.CreateScoring do
  use Ecto.Migration

  def change do
    create table(:scoring) do
      add :judge_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
