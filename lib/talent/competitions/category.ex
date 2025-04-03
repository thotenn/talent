defmodule Talent.Competitions.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :max_points, :integer
    field :father, :boolean, default: false

    belongs_to :parent_category, Talent.Competitions.Category, foreign_key: :father_id
    has_many :child_categories, Talent.Competitions.Category, foreign_key: :father_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :max_points, :father, :father_id])
    |> validate_required([:name, :description])
    |> validate_father_category()
    |> foreign_key_constraint(:father_id)
  end

  # Custom validation for father categories
  defp validate_father_category(changeset) do
    is_father = get_field(changeset, :father)
    father_id = get_field(changeset, :father_id)
    max_points = get_field(changeset, :max_points)

    changeset = cond do
      # If it's a father category, it cannot have a father_id
      is_father && father_id != nil ->
        add_error(changeset, :father_id, "una categoría padre no puede tener una categoría padre")

      # If it's a father category, max_points should be nil or 0
      is_father && max_points != nil && max_points > 0 ->
        changeset
        |> put_change(:max_points, nil)

      # If it has a father_id, it cannot be a father
      !is_father && father_id != nil ->
        # Ensure it's not a father
        changeset
        |> put_change(:father, false)

      true ->
        changeset
    end

    changeset
  end
end
