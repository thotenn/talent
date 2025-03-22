defmodule Talent.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  import Ecto.Query, warn: false
  alias Talent.Repo

  alias Talent.Dashboard.DashboardInfo

  @doc """
  Returns the list of dashboard_infos.

  ## Examples

      iex> list_dashboard_infos()
      [%DashboardInfo{}, ...]

  """
  def list_dashboard_infos do
    Repo.all(DashboardInfo)
  end

  @doc """
  Gets a single dashboard_info.

  Raises `Ecto.NoResultsError` if the Dashboard info does not exist.

  ## Examples

      iex> get_dashboard_info!(123)
      %DashboardInfo{}

      iex> get_dashboard_info!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dashboard_info!(id), do: Repo.get!(DashboardInfo, id)

  @doc """
  Creates a dashboard_info.

  ## Examples

      iex> create_dashboard_info(%{field: value})
      {:ok, %DashboardInfo{}}

      iex> create_dashboard_info(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dashboard_info(attrs \\ %{}) do
    %DashboardInfo{}
    |> DashboardInfo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dashboard_info.

  ## Examples

      iex> update_dashboard_info(dashboard_info, %{field: new_value})
      {:ok, %DashboardInfo{}}

      iex> update_dashboard_info(dashboard_info, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dashboard_info(%DashboardInfo{} = dashboard_info, attrs) do
    dashboard_info
    |> DashboardInfo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dashboard_info.

  ## Examples

      iex> delete_dashboard_info(dashboard_info)
      {:ok, %DashboardInfo{}}

      iex> delete_dashboard_info(dashboard_info)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dashboard_info(%DashboardInfo{} = dashboard_info) do
    Repo.delete(dashboard_info)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dashboard_info changes.

  ## Examples

      iex> change_dashboard_info(dashboard_info)
      %Ecto.Changeset{data: %DashboardInfo{}}

  """
  def change_dashboard_info(%DashboardInfo{} = dashboard_info, attrs \\ %{}) do
    DashboardInfo.changeset(dashboard_info, attrs)
  end
end
