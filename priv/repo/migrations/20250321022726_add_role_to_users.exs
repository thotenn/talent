defmodule Talent.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, default: "secretario"
    end

    create index(:users, [:role])
  end
end
