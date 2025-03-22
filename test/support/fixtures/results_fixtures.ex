defmodule Talent.ResultsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Talent.Results` context.
  """

  @doc """
  Generate a results_live.
  """
  def results_live_fixture(attrs \\ %{}) do
    {:ok, results_live} =
      attrs
      |> Enum.into(%{
        category_id: 42
      })
      |> Talent.Results.create_results_live()

    results_live
  end
end
