defmodule Talent.ScoringFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Talent.Scoring` context.
  """

  @doc """
  Generate a scoring_criterion.
  """
  def scoring_criterion_fixture(attrs \\ %{}) do
    {:ok, scoring_criterion} =
      attrs
      |> Enum.into(%{
        description: "some description",
        max_points: 42,
        name: "some name"
      })
      |> Talent.Scoring.create_scoring_criterion()

    scoring_criterion
  end

  @doc """
  Generate a score.
  """
  def score_fixture(attrs \\ %{}) do
    {:ok, score} =
      attrs
      |> Enum.into(%{
        value: 120.5
      })
      |> Talent.Scoring.create_score()

    score
  end

  @doc """
  Generate a scoring_live.
  """
  def scoring_live_fixture(attrs \\ %{}) do
    {:ok, scoring_live} =
      attrs
      |> Enum.into(%{
        judge_id: 42
      })
      |> Talent.Scoring.create_scoring_live()

    scoring_live
  end
end
