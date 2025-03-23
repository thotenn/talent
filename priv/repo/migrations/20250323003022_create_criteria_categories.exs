defmodule Talent.Repo.Migrations.CreateCriteriaCategories do
  use Ecto.Migration

  def change do
    create table(:criteria_categories) do
      add :criterion_id, references(:scoring_criteria, on_delete: :delete_all), null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:criteria_categories, [:criterion_id])
    create index(:criteria_categories, [:category_id])
    create unique_index(:criteria_categories, [:criterion_id, :category_id])

    # Añadir is_discount al esquema scoring_criteria
    alter table(:scoring_criteria) do
      add :is_discount, :boolean, default: false
    end

    # Eliminar la columna category_id si es que existe
    alter table(:scoring_criteria) do
      remove_if_exists :category_id
    end
  end
end
