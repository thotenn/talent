defmodule Talent.Scoring.CriterionCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "criteria_categories" do
    belongs_to :criterion, Talent.Scoring.ScoringCriterion
    belongs_to :category, Talent.Competitions.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(criterion_category, attrs) do
    criterion_category
    |> cast(attrs, [:criterion_id, :category_id])
    |> validate_required([:criterion_id, :category_id])
    |> foreign_key_constraint(:criterion_id)
    |> foreign_key_constraint(:category_id)
    |> unique_constraint([:criterion_id, :category_id])
  end
end
