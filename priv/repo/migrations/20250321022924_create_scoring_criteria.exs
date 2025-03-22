defmodule Talent.Repo.Migrations.CreateScoringCriteria do
  use Ecto.Migration

  def change do
    create table(:scoring_criteria) do
      add :name, :string
      add :description, :text
      add :max_points, :integer
      add :category_id, references(:categories, on_delete: :nothing)
      add :parent_id, references(:scoring_criteria, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:scoring_criteria, [:category_id])
    create index(:scoring_criteria, [:parent_id])
  end
end
