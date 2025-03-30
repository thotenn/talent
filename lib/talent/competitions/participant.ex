defmodule Talent.Competitions.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participants" do
    field :name, :string
    belongs_to :category, Talent.Competitions.Category
    belongs_to :person, Talent.Directory.PersonInfo

    # Campos virtuales para manejar personas en el mismo formulario
    field :person_data, :map, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name, :category_id, :person_id])
    |> cast_person(attrs)
    |> validate_required([:name])
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:person_id)
  end

  # Maneja datos anidados de la persona
  defp cast_person(changeset, attrs) do
    person_data = Map.get(attrs, "person_data") || Map.get(attrs, :person_data)

    if is_map(person_data) && map_size(person_data) > 0 do
      changeset |> put_change(:person_data, person_data)
    else
      changeset
    end
  end
end
