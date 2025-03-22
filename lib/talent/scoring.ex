defmodule Talent.Scoring do
  @moduledoc """
  The Scoring context.
  """

  import Ecto.Query, warn: false
  alias Talent.Repo

  alias Talent.Scoring.ScoringCriterion

  @doc """
  Returns the list of scoring_criteria.

  ## Examples

      iex> list_scoring_criteria()
      [%ScoringCriterion{}, ...]

  """
def list_scoring_criteria do
  Repo.all(ScoringCriterion)
  |> Repo.preload([:category, :parent, :sub_criteria])
end

  @doc """
  Gets a single scoring_criterion.

  Raises `Ecto.NoResultsError` if the Scoring criterion does not exist.

  ## Examples

      iex> get_scoring_criterion!(123)
      %ScoringCriterion{}

      iex> get_scoring_criterion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scoring_criterion!(id), do: Repo.get!(ScoringCriterion, id)

  @doc """
  Creates a scoring_criterion.

  ## Examples

      iex> create_scoring_criterion(%{field: value})
      {:ok, %ScoringCriterion{}}

      iex> create_scoring_criterion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scoring_criterion(attrs \\ %{}) do
    %ScoringCriterion{}
    |> ScoringCriterion.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, criterion} ->
        {:ok, Repo.preload(criterion, [:category, :parent, :sub_criteria])}
      error ->
        error
    end
  end
  @doc """
  Updates a scoring_criterion.

  ## Examples

      iex> update_scoring_criterion(scoring_criterion, %{field: new_value})
      {:ok, %ScoringCriterion{}}

      iex> update_scoring_criterion(scoring_criterion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scoring_criterion(%ScoringCriterion{} = scoring_criterion, attrs) do
    scoring_criterion
    |> ScoringCriterion.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, criterion} ->
        {:ok, Repo.preload(criterion, [:category, :parent, :sub_criteria])}
      error ->
        error
    end
  end

  @doc """
  Deletes a scoring_criterion.

  ## Examples

      iex> delete_scoring_criterion(scoring_criterion)
      {:ok, %ScoringCriterion{}}

      iex> delete_scoring_criterion(scoring_criterion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scoring_criterion(%ScoringCriterion{} = scoring_criterion) do
    Repo.delete(scoring_criterion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scoring_criterion changes.

  ## Examples

      iex> change_scoring_criterion(scoring_criterion)
      %Ecto.Changeset{data: %ScoringCriterion{}}

  """
  def change_scoring_criterion(%ScoringCriterion{} = scoring_criterion, attrs \\ %{}) do
    ScoringCriterion.changeset(scoring_criterion, attrs)
  end

  alias Talent.Scoring.Score

  @doc """
  Returns the list of scores.

  ## Examples

      iex> list_scores()
      [%Score{}, ...]

  """
  def list_scores do
    Repo.all(Score)
  end

  @doc """
  Gets a single score.

  Raises `Ecto.NoResultsError` if the Score does not exist.

  ## Examples

      iex> get_score!(123)
      %Score{}

      iex> get_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_score!(id), do: Repo.get!(Score, id)

  @doc """
  Creates a score.

  ## Examples

      iex> create_score(%{field: value})
      {:ok, %Score{}}

      iex> create_score(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_score(attrs \\ %{}) do
    %Score{}
    |> Score.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a score.

  ## Examples

      iex> update_score(score, %{field: new_value})
      {:ok, %Score{}}

      iex> update_score(score, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_score(%Score{} = score, attrs) do
    score
    |> Score.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a score.

  ## Examples

      iex> delete_score(score)
      {:ok, %Score{}}

      iex> delete_score(score)
      {:error, %Ecto.Changeset{}}

  """
  def delete_score(%Score{} = score) do
    Repo.delete(score)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking score changes.

  ## Examples

      iex> change_score(score)
      %Ecto.Changeset{data: %Score{}}

  """
  def change_score(%Score{} = score, attrs \\ %{}) do
    Score.changeset(score, attrs)
  end

    @doc """
  Gets a list of root scoring criteria for a specific category.
  """
  def list_root_scoring_criteria_by_category(category_id) do
    ScoringCriterion
    |> where([sc], sc.category_id == ^category_id and is_nil(sc.parent_id))
    |> Repo.all()
    |> Repo.preload(:sub_criteria)
  end

  @doc """
  Gets all scores for a participant.
  """
  def get_participant_scores(participant_id) do
    Score
    |> where([s], s.participant_id == ^participant_id)
    |> Repo.all()
    |> Repo.preload([:judge, :criterion])
  end

  @doc """
  Gets a judge's scores for a participant.
  """
  def get_judge_scores_for_participant(judge_id, participant_id) do
    Score
    |> where([s], s.judge_id == ^judge_id and s.participant_id == ^participant_id)
    |> Repo.all()
    |> Repo.preload(:criterion)
  end

  @doc """
  Calculates the total score for a participant across all judges.
  """
  def calculate_total_score(participant_id) do
    query = from s in Score,
            where: s.participant_id == ^participant_id,
            select: sum(s.value)

    Repo.one(query) || 0
  end

  @doc """
  Calculates the average score for a participant by criterion.
  """
  def calculate_average_score_by_criterion(participant_id, criterion_id) do
    query = from s in Score,
            where: s.participant_id == ^participant_id and s.criterion_id == ^criterion_id,
            select: avg(s.value)

    Repo.one(query) || 0
  end

  alias Talent.Scoring.ScoringLive

  @doc """
  Returns the list of scoring.

  ## Examples

      iex> list_scoring()
      [%ScoringLive{}, ...]

  """
  def list_scoring do
    Repo.all(ScoringLive)
  end

  @doc """
  Gets a single scoring_live.

  Raises `Ecto.NoResultsError` if the Scoring live does not exist.

  ## Examples

      iex> get_scoring_live!(123)
      %ScoringLive{}

      iex> get_scoring_live!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scoring_live!(id), do: Repo.get!(ScoringLive, id)

  @doc """
  Creates a scoring_live.

  ## Examples

      iex> create_scoring_live(%{field: value})
      {:ok, %ScoringLive{}}

      iex> create_scoring_live(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scoring_live(attrs \\ %{}) do
    %ScoringLive{}
    |> ScoringLive.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scoring_live.

  ## Examples

      iex> update_scoring_live(scoring_live, %{field: new_value})
      {:ok, %ScoringLive{}}

      iex> update_scoring_live(scoring_live, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scoring_live(%ScoringLive{} = scoring_live, attrs) do
    scoring_live
    |> ScoringLive.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scoring_live.

  ## Examples

      iex> delete_scoring_live(scoring_live)
      {:ok, %ScoringLive{}}

      iex> delete_scoring_live(scoring_live)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scoring_live(%ScoringLive{} = scoring_live) do
    Repo.delete(scoring_live)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scoring_live changes.

  ## Examples

      iex> change_scoring_live(scoring_live)
      %Ecto.Changeset{data: %ScoringLive{}}

  """
  def change_scoring_live(%ScoringLive{} = scoring_live, attrs \\ %{}) do
    ScoringLive.changeset(scoring_live, attrs)
  end

  @doc """
  Updates or inserts a score.
  """
  def upsert_score(attrs) do
    score_query = from s in Score,
      where: s.judge_id == ^attrs.judge_id and
            s.participant_id == ^attrs.participant_id and
            s.criterion_id == ^attrs.criterion_id

    # Convertir el valor a entero si viene como string
    attrs = if is_binary(attrs.value) do
      # Primero intentamos convertir a float y luego a entero
      # Esto es útil si tienes valores como "8.5" que deberían convertirse a 8 o 9
      value =
        case Float.parse(attrs.value) do
          {float_val, _} -> round(float_val)
          :error -> 0 # valor por defecto si no se puede convertir
        end
      Map.put(attrs, :value, value)
    else
      # Si ya es un entero o float, nos aseguramos de que sea entero
      value = if is_float(attrs.value), do: round(attrs.value), else: attrs.value
      Map.put(attrs, :value, value)
    end

    case Repo.one(score_query) do
      nil ->
        %Score{}
        |> Score.changeset(attrs)
        |> Repo.insert()

      existing_score ->
        existing_score
        |> Score.changeset(attrs)
        |> Repo.update()
    end
  end
end
