defmodule Talent.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :value, :float
      add :judge_id, references(:judges, on_delete: :nothing)
      add :participant_id, references(:participants, on_delete: :nothing)
      add :criterion_id, references(:scoring_criteria, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:scores, [:judge_id])
    create index(:scores, [:participant_id])
    create index(:scores, [:criterion_id])
  end
end
