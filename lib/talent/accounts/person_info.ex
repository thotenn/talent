defmodule Talent.Accounts.PersonInfo do
  use Ecto.Schema
  import Ecto.Changeset

  @gender_options ["Masculino", "Femenino", "Otros", "Prefiero no decirlo"]

  schema "people_info" do
    field :full_name, :string
    field :short_name, :string
    field :phone, :string
    field :identity_number, :string
    field :birth_date, :date
    field :gender, :string
    field :extra_data, :string

    # La relación many_to_many debe usar person_id como foreign_key
    many_to_many :networks, Talent.Accounts.Network,
      join_through: Talent.Accounts.PersonNetwork,
      join_keys: [person_id: :id, network_id: :id]

    # Asegurarse de que esta relación use person_id y no person_info_id
    has_many :person_networks, Talent.Accounts.PersonNetwork,
      foreign_key: :person_id

    # Relaciones uno a uno (1:1)
    has_one :user, Talent.Accounts.User
    has_one :participant, Talent.Competitions.Participant

    # Campo virtual para poder recibir las redes sociales de forma anidada en formularios
    field :networks_data, {:array, :map}, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(person_info, attrs) do
    person_info
    |> cast(attrs, [:full_name, :short_name, :phone, :identity_number, :birth_date, :gender, :extra_data])
    |> validate_required([:full_name])
    |> validate_inclusion(:gender, @gender_options, message: "debe ser uno de: #{Enum.join(@gender_options, ", ")}")
    |> cast_networks(attrs)
  end

  defp cast_networks(changeset, attrs) do
    networks_data = Map.get(attrs, "networks_data", [])

    if is_list(networks_data) and length(networks_data) > 0 do
      changeset
      |> put_change(:networks_data, networks_data)
    else
      changeset
    end
  end

  def gender_options, do: @gender_options
end
