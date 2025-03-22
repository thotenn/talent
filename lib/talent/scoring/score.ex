defmodule Talent.Scoring.Score do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scores" do
    field :value, :integer

    belongs_to :judge, Talent.Competitions.Judge
    belongs_to :participant, Talent.Competitions.Participant
    belongs_to :criterion, Talent.Scoring.ScoringCriterion

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(score, attrs) do
    score
    |> cast(attrs, [:value, :judge_id, :participant_id, :criterion_id])
    |> validate_required([:value, :judge_id, :participant_id, :criterion_id])
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:judge_id)
    |> foreign_key_constraint(:participant_id)
    |> foreign_key_constraint(:criterion_id)
    |> unique_constraint([:judge_id, :participant_id, :criterion_id], name: :judge_participant_criterion_index)
  end
end
