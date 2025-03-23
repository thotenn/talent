defmodule Talent.Repo.Migrations.CreateJudgeCriteriaTable do
  use Ecto.Migration

  def change do
    create table(:judge_criteria) do
      add :judge_id, references(:judges, on_delete: :delete_all), null: false
      add :criterion_id, references(:scoring_criteria, on_delete: :delete_all), null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:judge_criteria, [:judge_id])
    create index(:judge_criteria, [:criterion_id])
    create index(:judge_criteria, [:category_id])
    create unique_index(:judge_criteria, [:judge_id, :criterion_id, :category_id], name: :judge_criterion_category_index)
  end
end
