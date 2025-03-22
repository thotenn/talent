defmodule Talent.Repo.Migrations.UpdateScoreValueType do
  use Ecto.Migration

  def change do
    alter table(:scores) do
      modify :value, :integer, from: :float
    end
  end
end
