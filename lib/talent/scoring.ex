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
    # First check if there are any sub-criteria
    sub_criteria_count =
      from(sc in ScoringCriterion, where: sc.parent_id == ^scoring_criterion.id)
      |> Repo.aggregate(:count, :id)

    if sub_criteria_count > 0 do
      {:error, "No se puede eliminar el criterio porque tiene subcriterios asociados"}
    else
      # Check if there are scores associated with this criterion
      scores_count =
        from(s in Talent.Scoring.Score, where: s.criterion_id == ^scoring_criterion.id)
        |> Repo.aggregate(:count, :id)

      if scores_count > 0 do
        {:error, "No se puede eliminar el criterio porque hay puntuaciones asociadas"}
      else
        # It's safe to delete the criterion
        Repo.delete(scoring_criterion)
      end
    end
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
  Updates or inserts a score.
  """
  def upsert_score(attrs) do
    score_query = from s in Score,
      where: s.judge_id == ^attrs.judge_id and
            s.participant_id == ^attrs.participant_id and
            s.criterion_id == ^attrs.criterion_id

    # Asegurar que el valor sea un entero para almacenamiento
    attrs =
      cond do
        is_binary(attrs.value) ->
          case Float.parse(attrs.value) do
            {float_val, _} -> Map.put(attrs, :value, round(float_val))
            :error -> Map.put(attrs, :value, 0)
          end
        is_float(attrs.value) ->
          Map.put(attrs, :value, round(attrs.value))
        is_integer(attrs.value) ->
          attrs
        true ->
          Map.put(attrs, :value, 0)
      end

    result = case Repo.one(score_query) do
      nil ->
        %Score{}
        |> Score.changeset(attrs)
        |> Repo.insert()

      existing_score ->
        existing_score
        |> Score.changeset(attrs)
        |> Repo.update()
    end

    # En caso de éxito, transmitir el evento de actualización
    case result do
      {:ok, _score} ->
        # Obtener información de la categoría del participante
        participant = Talent.Competitions.get_participant!(attrs.participant_id)
        # Emitir evento con la categoría para que los suscriptores puedan filtrar
        IO.puts("thotenn.Emitiendo evento de actualización para categoría: #{participant.category_id}")
        Phoenix.PubSub.broadcast(
          Talent.PubSub,
          "scores:updates",
          {:score_updated, %{category_id: participant.category_id}}
        )
        result
      _ ->
        result
    end
  end
end
