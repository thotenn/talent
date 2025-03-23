defmodule Talent.Scoring.JudgeCriterion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "judge_criteria" do
    belongs_to :judge, Talent.Competitions.Judge
    belongs_to :criterion, Talent.Scoring.ScoringCriterion
    belongs_to :category, Talent.Competitions.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(judge_criterion, attrs) do
    judge_criterion
    |> cast(attrs, [:judge_id, :criterion_id, :category_id])
    |> validate_required([:judge_id, :criterion_id, :category_id])
    |> foreign_key_constraint(:judge_id)
    |> foreign_key_constraint(:criterion_id)
    |> foreign_key_constraint(:category_id)
    |> unique_constraint([:judge_id, :criterion_id, :category_id], name: :judge_criterion_category_index)
  end
end
