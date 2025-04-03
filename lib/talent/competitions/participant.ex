defmodule Talent.Competitions.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participants" do
    field :name, :string
    belongs_to :category, Talent.Competitions.Category

    belongs_to :person, Talent.Accounts.PersonInfo

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name, :category_id, :person_id])
    |> validate_required([:name])
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:person_id)
  end
end
