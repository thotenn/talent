defmodule Talent.Competitions.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :max_points, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :max_points])
    |> validate_required([:name, :description, :max_points])
  end
end
