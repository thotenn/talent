defmodule Talent.Scoring.ScoringCriterion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scoring_criteria" do
    field :name, :string
    field :description, :string
    field :max_points, :integer

    belongs_to :category, Talent.Competitions.Category
    belongs_to :parent, Talent.Scoring.ScoringCriterion, foreign_key: :parent_id
    has_many :sub_criteria, Talent.Scoring.ScoringCriterion, foreign_key: :parent_id
    has_many :scores, Talent.Scoring.Score, foreign_key: :criterion_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scoring_criterion, attrs) do
    scoring_criterion
    |> cast(attrs, [:name, :description, :category_id, :parent_id, :max_points])
    |> validate_required([:name, :category_id])
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:id, name: "scores_criterion_id_fkey", message: "No se puede eliminar el criterio porque hay puntuaciones asociadas")
  end
end
