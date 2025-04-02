defmodule Talent.Accounts.PersonNetwork do
  use Ecto.Schema
  import Ecto.Changeset

  schema "person_networks" do
    field :username, :string
    field :url, :string

    belongs_to :person, Talent.Accounts.PersonInfo
    belongs_to :network, Talent.Accounts.Network

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(person_network, attrs) do
    person_network
    |> cast(attrs, [:person_id, :network_id, :username, :url])
    |> validate_required([:person_id, :network_id, :username])
    |> foreign_key_constraint(:person_id)
    |> foreign_key_constraint(:network_id)
    |> unique_constraint([:person_id, :network_id], name: :person_network_unique_index)
    |> maybe_generate_url()
  end

  defp maybe_generate_url(changeset) do
    if username = get_change(changeset, :username) do
      case fetch_change(changeset, :network_id) do
        {:ok, network_id} ->
          network = Talent.Repo.get(Talent.Accounts.Network, network_id)
          if network && !get_change(changeset, :url) do
            put_change(changeset, :url, "#{network.base_url}#{username}")
          else
            changeset
          end
        _ ->
          changeset
      end
    else
      changeset
    end
  end
end
