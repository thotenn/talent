defmodule Talent.Repo.Migrations.AddParentChildRelationshipsToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :father, :boolean, default: false
      add :father_id, references(:categories, on_delete: :nilify_all)
    end

    create index(:categories, [:father])
    create index(:categories, [:father_id])
  end
end
