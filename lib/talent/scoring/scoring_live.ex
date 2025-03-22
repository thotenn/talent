defmodule Talent.Scoring.ScoringLive do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scoring" do
    field :judge_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scoring_live, attrs) do
    scoring_live
    |> cast(attrs, [:judge_id])
    |> validate_required([:judge_id])
  end
end
