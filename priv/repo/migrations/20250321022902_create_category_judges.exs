defmodule Talent.Repo.Migrations.CreateCategoryJudges do
  use Ecto.Migration

  def change do
    create table(:category_judges) do
      add :category_id, references(:categories, on_delete: :nothing)
      add :judge_id, references(:judges, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:category_judges, [:category_id])
    create index(:category_judges, [:judge_id])
  end
end
