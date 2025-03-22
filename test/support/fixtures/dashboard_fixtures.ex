defmodule Talent.DashboardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Talent.Dashboard` context.
  """

  @doc """
  Generate a dashboard_info.
  """
  def dashboard_info_fixture(attrs \\ %{}) do
    {:ok, dashboard_info} =
      attrs
      |> Enum.into(%{

      })
      |> Talent.Dashboard.create_dashboard_info()

    dashboard_info
  end
end
