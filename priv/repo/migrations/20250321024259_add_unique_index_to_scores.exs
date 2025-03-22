defmodule Talent.Repo.Migrations.AddUniqueIndexToScores do
  use Ecto.Migration

  def change do
    create unique_index(:scores, [:judge_id, :participant_id, :criterion_id], name: :judge_participant_criterion_index)
  end
end
