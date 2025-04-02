defmodule Talent.Accounts.Network do
  use Ecto.Schema
  import Ecto.Changeset

  schema "networks" do
    field :name, :string
    field :base_url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(network, attrs) do
    network
    |> cast(attrs, [:name, :base_url])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
