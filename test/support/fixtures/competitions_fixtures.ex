defmodule Talent.CompetitionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Talent.Competitions` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        max_points: 42,
        name: "some name"
      })
      |> Talent.Competitions.create_category()

    category
  end

  @doc """
  Generate a judge.
  """
  def judge_fixture(attrs \\ %{}) do
    {:ok, judge} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Talent.Competitions.create_judge()

    judge
  end

  @doc """
  Generate a category_judge.
  """
  def category_judge_fixture(attrs \\ %{}) do
    {:ok, category_judge} =
      attrs
      |> Enum.into(%{

      })
      |> Talent.Competitions.create_category_judge()

    category_judge
  end

  @doc """
  Generate a participant.
  """
  def participant_fixture(attrs \\ %{}) do
    {:ok, participant} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Talent.Competitions.create_participant()

    participant
  end
end
