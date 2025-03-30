defmodule Talent.Repo.Migrations.AddPersonReferencesToUsersAndParticipants do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :person_id, references(:people_info, on_delete: :nilify_all)
    end

    alter table(:participants) do
      add :person_id, references(:people_info, on_delete: :nilify_all)
    end

    create index(:users, [:person_id])
    create index(:participants, [:person_id])
  end
end
