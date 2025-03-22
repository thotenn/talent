defmodule Talent.Repo.Migrations.AddScoresAccessToJudges do
  use Ecto.Migration

  def change do
    alter table(:judges) do
      add :scores_access, :boolean, default: false
    end

    create index(:judges, [:scores_access])
  end
end
