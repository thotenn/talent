defmodule Talent.Results do
  @moduledoc """
  The Results context.
  """

  import Ecto.Query, warn: false
  alias Talent.Repo

  alias Talent.Results.ResultsLive

  @doc """
  Returns the list of results.

  ## Examples

      iex> list_results()
      [%ResultsLive{}, ...]

  """
  def list_results do
    Repo.all(ResultsLive)
  end

  @doc """
  Gets a single results_live.

  Raises `Ecto.NoResultsError` if the Results live does not exist.

  ## Examples

      iex> get_results_live!(123)
      %ResultsLive{}

      iex> get_results_live!(456)
      ** (Ecto.NoResultsError)

  """
  def get_results_live!(id), do: Repo.get!(ResultsLive, id)

  @doc """
  Creates a results_live.

  ## Examples

      iex> create_results_live(%{field: value})
      {:ok, %ResultsLive{}}

      iex> create_results_live(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_results_live(attrs \\ %{}) do
    %ResultsLive{}
    |> ResultsLive.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a results_live.

  ## Examples

      iex> update_results_live(results_live, %{field: new_value})
      {:ok, %ResultsLive{}}

      iex> update_results_live(results_live, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_results_live(%ResultsLive{} = results_live, attrs) do
    results_live
    |> ResultsLive.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a results_live.

  ## Examples

      iex> delete_results_live(results_live)
      {:ok, %ResultsLive{}}

      iex> delete_results_live(results_live)
      {:error, %Ecto.Changeset{}}

  """
  def delete_results_live(%ResultsLive{} = results_live) do
    Repo.delete(results_live)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking results_live changes.

  ## Examples

      iex> change_results_live(results_live)
      %Ecto.Changeset{data: %ResultsLive{}}

  """
  def change_results_live(%ResultsLive{} = results_live, attrs \\ %{}) do
    ResultsLive.changeset(results_live, attrs)
  end
end
