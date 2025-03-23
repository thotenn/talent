defmodule Talent.Scoring do
  @moduledoc """
  The Scoring context.
  """

  import Ecto.Query, warn: false
  alias Talent.Repo

  alias Talent.Scoring.ScoringCriterion
  alias Talent.Scoring.JudgeCriterion

  @doc """
  Returns the list of scoring_criteria.

  ## Examples

      iex> list_scoring_criteria()
      [%ScoringCriterion{}, ...]

  """
  def list_scoring_criteria do
    Repo.all(ScoringCriterion)
    |> Repo.preload([:categories, :parent, :sub_criteria])
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
  def get_scoring_criterion!(id) do
    Repo.get!(ScoringCriterion, id)
    |> Repo.preload([:categories, :parent, :sub_criteria])
  end

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
        {:ok, Repo.preload(criterion, [:categories, :parent, :sub_criteria])}
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
        {:ok, Repo.preload(criterion, [:categories, :parent, :sub_criteria])}
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
    # En lugar de buscar por category_id directamente,
    # debemos hacerlo a través de la tabla de unión criteria_categories
    query = from cc in Talent.Scoring.CriterionCategory,
            where: cc.category_id == ^category_id,
            join: sc in Talent.Scoring.ScoringCriterion, on: sc.id == cc.criterion_id,
            where: is_nil(sc.parent_id),
            select: sc

    Repo.all(query)
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

  @spec get_judge_scores_for_participant(any(), any()) ::
          nil | [%{optional(atom()) => any()}] | %{optional(atom()) => any()}
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
  Asigna múltiples categorías a un criterio de puntuación.
  """
  def assign_categories_to_criterion(criterion_id, category_ids) when is_list(category_ids) do
    # Primero eliminamos todas las asignaciones existentes
    from(cc in Talent.Scoring.CriterionCategory, where: cc.criterion_id == ^criterion_id)
    |> Repo.delete_all()

    # Luego creamos las nuevas asignaciones
    Enum.map(category_ids, fn category_id when not is_nil(category_id) ->
      %Talent.Scoring.CriterionCategory{}
      |> Talent.Scoring.CriterionCategory.changeset(%{
        criterion_id: criterion_id,
        category_id: category_id
      })
      |> Repo.insert()
    end)
  end

  @doc """
  Obtiene todas las categorías asignadas a un criterio de puntuación.
  """
  def get_categories_for_criterion(criterion_id) do
    Talent.Scoring.CriterionCategory
    |> where([cc], cc.criterion_id == ^criterion_id)
    |> join(:inner, [cc], c in Talent.Competitions.Category, on: c.id == cc.category_id)
    |> select([_cc, c], c)
    |> Repo.all()
  end

  @doc """
  Obtiene todos los criterios de puntuación asignados a una categoría.
  """
  def list_scoring_criteria_by_category(category_id) do
    Talent.Scoring.CriterionCategory
    |> where([cc], cc.category_id == ^category_id)
    |> join(:inner, [cc], sc in Talent.Scoring.ScoringCriterion, on: sc.id == cc.criterion_id)
    |> select([_cc, sc], sc)
    |> Repo.all()
  end

  @doc """
  Modifica la función para considerar criterios que son descuentos.
  """
  def calculate_total_score(participant_id) do
    # Obtener todos los scores del participante con sus criterios
    scores_query = from s in Score,
                  where: s.participant_id == ^participant_id,
                  join: sc in Talent.Scoring.ScoringCriterion, on: s.criterion_id == sc.id,
                  select: {s.value, sc.is_discount}

    # Calcular el total teniendo en cuenta si son descuentos o no
    Repo.all(scores_query)
    |> Enum.reduce(0, fn
      {value, true}, acc -> acc - value  # Si es descuento, restar
      {value, false}, acc -> acc + value # Si no es descuento, sumar
    end)
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

  @doc """
  Asigna un criterio a un juez para una categoría específica, incluyendo automáticamente sus criterios padre.
  Sin embargo, NO asigna automáticamente los criterios hijo.
  """
  def assign_criterion_to_judge(judge_id, criterion_id, category_id) do
    # Obtener el criterio para verificar si tiene padre
    criterion = Repo.get(Talent.Scoring.ScoringCriterion, criterion_id)

    # Cargar el padre si existe y asignarlo primero
    if criterion && criterion.parent_id do
      # Primero asignar el padre recursivamente
      assign_criterion_to_judge(judge_id, criterion.parent_id, category_id)
    end

    # Asignar el criterio actual (NO asignamos automáticamente los hijos)
    result = %JudgeCriterion{}
      |> JudgeCriterion.changeset(%{judge_id: judge_id, criterion_id: criterion_id, category_id: category_id})
      |> Repo.insert(on_conflict: :nothing)

    # Ajustar la respuesta
    case result do
      {:ok, record} -> {:ok, record}
      {:error, changeset} ->
        if Keyword.has_key?(changeset.errors, :judge_id) and
          elem(Keyword.get(changeset.errors, :judge_id), 0) == "has already been taken" do
          # Es un caso de duplicación, lo tratamos como éxito
          {:ok, %JudgeCriterion{judge_id: judge_id, criterion_id: criterion_id, category_id: category_id}}
        else
          # Es un error real
          {:error, changeset}
        end
    end
  end

  @doc """
  Elimina la asignación de un criterio a un juez para una categoría específica
  y todas las puntuaciones relacionadas con ese criterio.
  """
  def unassign_criterion_from_judge(judge_id, criterion_id, category_id) do
    # Primero obtenemos todos los participantes de esta categoría
    participants = Talent.Competitions.list_participants_by_category(category_id)
    participant_ids = Enum.map(participants, & &1.id)

    # Eliminar todas las puntuaciones para este juez, criterio y participantes de la categoría
    {deleted_scores_count, _} =
      from(s in Talent.Scoring.Score,
        where: s.judge_id == ^judge_id and
              s.criterion_id == ^criterion_id and
              s.participant_id in ^participant_ids)
      |> Repo.delete_all()

    # Eliminar la asignación del criterio
    {deleted_assignments_count, _} =
      from(jc in JudgeCriterion,
        where: jc.judge_id == ^judge_id and
              jc.criterion_id == ^criterion_id and
              jc.category_id == ^category_id)
      |> Repo.delete_all()

    # Devolver información sobre lo que se eliminó
    %{deleted_scores: deleted_scores_count, deleted_assignments: deleted_assignments_count}
  end

  @doc """
  Asigna criterios y todos sus criterios padre a un juez para una categoría específica.
  Útil para asignación masiva.
  """
  def assign_all_parent_criteria(judge_id, criterion_ids, category_id) when is_list(criterion_ids) do
    # Para cada criterio en la lista, asignar tanto el criterio como sus padres
    Enum.map(criterion_ids, fn criterion_id ->
      assign_criterion_to_judge(judge_id, criterion_id, category_id)
    end)
  end

  @doc """
  Función de utilidad para obtener todos los criterios padre de un criterio específico.
  """
  def get_all_parent_criteria(criterion_id) do
    # Obtener el criterio con su padre
    criterion = Repo.get(Talent.Scoring.ScoringCriterion, criterion_id)

    # Cargar el padre si existe
    if criterion && criterion.parent_id do
      parent = Repo.get(Talent.Scoring.ScoringCriterion, criterion.parent_id)

      if parent do
        # Si el padre existe, incluirlo y buscar sus padres recursivamente
        [parent | get_all_parent_criteria(parent.id)]
      else
        []
      end
    else
      # Si no tiene padre, devolver lista vacía
      []
    end
  end

  @doc """
  Verifica si un criterio está asignado a un juez para una categoría específica.
  """
  def judge_has_criterion?(judge_id, criterion_id, category_id) do
    from(jc in JudgeCriterion,
      where: jc.judge_id == ^judge_id and
            jc.criterion_id == ^criterion_id and
            jc.category_id == ^category_id)
    |> Repo.exists?()
  end

  @doc """
  Obtiene todos los criterios asignados a un juez para una categoría específica.
  """
  def list_criteria_for_judge_in_category(judge_id, category_id) do
    from(jc in JudgeCriterion,
      where: jc.judge_id == ^judge_id and jc.category_id == ^category_id,
      join: c in Talent.Scoring.ScoringCriterion, on: c.id == jc.criterion_id,
      select: c)
    |> Repo.all()
  end

  @doc """
  Obtiene todos los criterios que un juez puede calificar.
  """
  def list_criteria_for_judge(judge_id) do
    from(jc in JudgeCriterion,
      where: jc.judge_id == ^judge_id,
      join: c in Talent.Scoring.ScoringCriterion, on: c.id == jc.criterion_id,
      join: cat in Talent.Competitions.Category, on: cat.id == jc.category_id,
      select: {c, cat})
    |> Repo.all()
  end

  @doc """
  Actualiza la función para considerar criterios que son descuentos y filtrar por los criterios asignados al juez.
  """
  def calculate_total_score_with_criteria_restriction(participant_id, judge_id) do
    # Obtener la categoría del participante
    participant = Talent.Competitions.get_participant!(participant_id) |> Repo.preload(:category)
    category_id = participant.category_id

    # Obtener los criterios asignados al juez para esta categoría
    judge_criteria = list_criteria_for_judge_in_category(judge_id, category_id)
    judge_criteria_ids = Enum.map(judge_criteria, & &1.id)

    # Obtener los scores del juez para este participante, filtrando por criterios asignados
    scores_query = from s in Talent.Scoring.Score,
                  where: s.participant_id == ^participant_id and s.judge_id == ^judge_id,
                  join: sc in Talent.Scoring.ScoringCriterion, on: s.criterion_id == sc.id,
                  where: s.criterion_id in ^judge_criteria_ids,
                  select: {s.value, sc.is_discount}

    # Calcular el total teniendo en cuenta si son descuentos o no
    Repo.all(scores_query)
    |> Enum.reduce(0, fn
      {value, true}, acc -> acc - value  # Si es descuento, restar
      {value, false}, acc -> acc + value # Si no es descuento, sumar
    end)
  end

end
