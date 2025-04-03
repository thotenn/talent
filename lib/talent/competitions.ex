defmodule Talent.Competitions do
  @moduledoc """
  The Competitions context.
  """

  import Ecto.Query, warn: false
  alias Talent.Repo

  alias Talent.Competitions.Category
  alias Talent.Accounts

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Category
    |> Repo.all()
    |> Repo.preload(:parent_category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Talent.Competitions.Judge

  @doc """
  Returns the list of judges.

  ## Examples

      iex> list_judges()
      [%Judge{}, ...]

  """
  def list_judges do
    Repo.all(Judge)
  end

  @doc """
  Gets a single judge.

  Raises `Ecto.NoResultsError` if the Judge does not exist.

  ## Examples

      iex> get_judge!(123)
      %Judge{}

      iex> get_judge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_judge!(id), do: Repo.get!(Judge, id) |> Repo.preload([:user, :categories])

  @doc """
  Creates a judge.

  ## Examples

      iex> create_judge(%{field: value})
      {:ok, %Judge{}}

      iex> create_judge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_judge(attrs \\ %{}) do
    %Judge{}
    |> Judge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a judge.

  ## Examples

      iex> update_judge(judge, %{field: new_value})
      {:ok, %Judge{}}

      iex> update_judge(judge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_judge(%Judge{} = judge, attrs) do
    judge
    |> Judge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a judge.

  ## Examples

      iex> delete_judge(judge)
      {:ok, %Judge{}}

      iex> delete_judge(judge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_judge(%Judge{} = judge) do
    # First delete all scores associated with this judge
    Repo.delete_all(from s in Talent.Scoring.Score, where: s.judge_id == ^judge.id)

    # Then delete all category_judge associations
    Repo.delete_all(from cj in Talent.Competitions.CategoryJudge, where: cj.judge_id == ^judge.id)

    # Now it's safe to delete the judge
    Repo.delete(judge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking judge changes.

  ## Examples

      iex> change_judge(judge)
      %Ecto.Changeset{data: %Judge{}}

  """
  def change_judge(%Judge{} = judge, attrs \\ %{}) do
    Judge.changeset(judge, attrs)
  end

  alias Talent.Competitions.CategoryJudge

  @doc """
  Returns the list of category_judges.

  ## Examples

      iex> list_category_judges()
      [%CategoryJudge{}, ...]

  """
  def list_category_judges do
    Repo.all(CategoryJudge)
  end

  @doc """
  Gets a single category_judge.

  Raises `Ecto.NoResultsError` if the Category judge does not exist.

  ## Examples

      iex> get_category_judge!(123)
      %CategoryJudge{}

      iex> get_category_judge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category_judge!(id), do: Repo.get!(CategoryJudge, id)

  @doc """
  Creates a category_judge.

  ## Examples

      iex> create_category_judge(%{field: value})
      {:ok, %CategoryJudge{}}

      iex> create_category_judge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category_judge(attrs \\ %{}) do
    %CategoryJudge{}
    |> CategoryJudge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category_judge.

  ## Examples

      iex> update_category_judge(category_judge, %{field: new_value})
      {:ok, %CategoryJudge{}}

      iex> update_category_judge(category_judge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category_judge(%CategoryJudge{} = category_judge, attrs) do
    category_judge
    |> CategoryJudge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category_judge.

  ## Examples

      iex> delete_category_judge(category_judge)
      {:ok, %CategoryJudge{}}

      iex> delete_category_judge(category_judge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category_judge(%CategoryJudge{} = category_judge) do
    Repo.delete(category_judge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category_judge changes.

  ## Examples

      iex> change_category_judge(category_judge)
      %Ecto.Changeset{data: %CategoryJudge{}}

  """
  def change_category_judge(%CategoryJudge{} = category_judge, attrs \\ %{}) do
    CategoryJudge.changeset(category_judge, attrs)
  end

  alias Talent.Competitions.Participant

  @doc """
  Returns the list of participants.

  ## Examples

      iex> list_participants()
      [%Participant{}, ...]

  """
  def list_participants do
    Repo.all(Participant)
  end

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id), do: Repo.get!(Participant, id) |> Repo.preload(:category)

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant(%Participant{} = participant) do
    # First delete all scores associated with this participant
    Repo.delete_all(from s in Talent.Scoring.Score, where: s.participant_id == ^participant.id)

    # Now it's safe to delete the participant
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{data: %Participant{}}

  """
  def change_participant(%Participant{} = participant, attrs \\ %{}) do
    Participant.changeset(participant, attrs)
  end

    @doc """
  Gets a list of judges assigned to a specific category.
  """
  def list_judges_by_category(category_id) do
    CategoryJudge
    |> where([cj], cj.category_id == ^category_id)
    |> join(:inner, [cj], j in Judge, on: j.id == cj.judge_id)
    |> select([_cj, j], j)
    |> Repo.all()
  end

  @doc """
  Gets a list of categories assigned to a specific judge.
  """
  def list_categories_by_judge(judge_id) do
    CategoryJudge
    |> where([cj], cj.judge_id == ^judge_id)
    |> join(:inner, [cj], c in Category, on: c.id == cj.category_id)
    |> select([_cj, c], c)
    |> Repo.all()
  end

  @doc """
  Assign a judge to a category.
  """
  def assign_judge_to_category(judge_id, category_id) do
    # Verificar si ya existe la asignación
    case CategoryJudge
        |> where([cj], cj.judge_id == ^judge_id and cj.category_id == ^category_id)
        |> Repo.one() do
      nil ->
        %CategoryJudge{}
        |> CategoryJudge.changeset(%{judge_id: judge_id, category_id: category_id})
        |> Repo.insert()
      existing ->
        {:ok, existing}
    end
  end

  @doc """
  Unassign a judge from a category.
  """
  def unassign_judge_from_category(judge_id, category_id) do
    CategoryJudge
    |> where([cj], cj.judge_id == ^judge_id and cj.category_id == ^category_id)
    |> Repo.delete_all()
  end

  @doc """
  Gets a judge by user_id.
  """
  def get_judge_by_user_id(user_id) do
    Judge
    |> Repo.get_by(user_id: user_id)
  end

  @doc """
  Lists participants by category.
  """
  def list_participants_by_category(category_id) do
    Participant
    |> where([p], p.category_id == ^category_id)
    |> Repo.all()
    |> Repo.preload(:category)
  end

  @doc """
  Checks if a judge is assigned to a category.
  """
  def judge_assigned_to_category?(judge_id, category_id) do
    CategoryJudge
    |> where([cj], cj.judge_id == ^judge_id and cj.category_id == ^category_id)
    |> Repo.exists?()
  end

  @doc """
  Creates a participant with associated person_info.
  """
  def create_participant_with_person_info(participant_params, person_info_params, networks_params) do
    Ecto.Multi.new()
    |> handle_person_info_for_create(person_info_params, networks_params)
    |> create_participant_with_person(participant_params)
    |> Talent.Repo.transaction()
  end

  @doc """
  Updates a participant with associated person_info.
  """
  def update_participant_with_person_info(%Participant{} = participant, participant_params, person_info_params, networks_params) do
    # Iniciar la transacción
    Ecto.Multi.new()
    |> handle_person_info_for_update(participant, person_info_params, networks_params)
    |> update_participant_with_person_id(participant, participant_params)
    |> Talent.Repo.transaction()
  end

  # Funciones privadas para manejar las transacciones

  defp handle_person_info_for_create(multi, person_info_params, networks_params) do
    # Si hay información personal válida, crearla
    if has_valid_person_info?(person_info_params) do
      multi
      |> Ecto.Multi.run(:person_info, fn _repo, _changes ->
        Accounts.create_person_info_with_networks(person_info_params, networks_params)
      end)
    else
      # No hay información personal, continuar sin ella
      multi
      |> Ecto.Multi.run(:person_info, fn _repo, _changes ->
        {:ok, %{person_info: nil}}
      end)
    end
  end

  defp handle_person_info_for_update(multi, participant, person_info_params, networks_params) do
    # Verificar si hay datos válidos de persona
    if has_valid_person_info?(person_info_params) do
      if participant.person_id do
        # Si ya tiene person_id, actualizar información existente
        multi
        |> Ecto.Multi.run(:person_info, fn _repo, _changes ->
          person_info = Talent.Accounts.get_person_info!(participant.person_id)
          Talent.Accounts.update_person_info_with_networks(person_info, person_info_params, networks_params)
        end)
      else
        # Si no tiene person_id, crear nueva información personal
        multi
        |> Ecto.Multi.run(:person_info, fn _repo, _changes ->
          Talent.Accounts.create_person_info_with_networks(person_info_params, networks_params)
        end)
      end
    else
      # No hay información personal válida
      multi
      |> Ecto.Multi.run(:person_info, fn _repo, _changes ->
        {:ok, %{person_info: nil}}
      end)
    end
  end

  defp create_participant_with_person(multi, participant_params) do
    multi
    |> Ecto.Multi.run(:participant, fn _repo, changes ->
      # Log para depuración
      IO.inspect(changes, label: "Cambios en la transacción para crear participante")

      # Si se creó información personal, asignarla al participante
      participant_params =
        case changes do
          %{person_info: person_info = %Talent.Accounts.PersonInfo{}} ->
            # Si recibimos directamente un objeto PersonInfo
            IO.puts("Encontrada información personal directa: #{inspect(person_info.id)}")
            Map.put(participant_params, "person_id", person_info.id)
          %{person_info: %{person_info: person_info}} when not is_nil(person_info) ->
            # Si recibimos la estructura anidada
            IO.puts("Encontrada información personal anidada: #{inspect(person_info.id)}")
            Map.put(participant_params, "person_id", person_info.id)
          _ ->
            IO.puts("No se encontró información personal válida para el nuevo participante")
            participant_params
        end

      # Log para verificar los parámetros finales
      IO.inspect(participant_params, label: "Parámetros finales para crear participante")

      # Crear el participante con los parámetros finales
      create_participant(participant_params)
    end)
  end

  defp update_participant_with_person_id(multi, participant, participant_params) do
    multi
    |> Ecto.Multi.run(:participant, fn _repo, changes ->
      # Log para depuración
      IO.inspect(changes, label: "Cambios en la transacción")

      # Verificar si tenemos una persona válida en los cambios
      participant_params =
        case changes do
          %{person_info: %{person_info: person_info}} when not is_nil(person_info) ->
            IO.puts("Encontrada información personal: #{inspect(person_info.id)}")
            Map.put(participant_params, "person_id", person_info.id)
          %{person_info: person_info} when is_map(person_info) and not is_nil(person_info.id) ->
            IO.puts("Encontrada información personal alternativa: #{inspect(person_info.id)}")
            Map.put(participant_params, "person_id", person_info.id)
          _ ->
            IO.puts("No se encontró información personal válida")
            participant_params
        end

      # Log para verificar los parámetros finales
      IO.inspect(participant_params, label: "Parámetros de participante finales")

      # Actualizar el participante con los parámetros finales
      result = update_participant(participant, participant_params)
      IO.inspect(result, label: "Resultado de actualización")
      result
    end)
  end

  # Verificar si hay información personal válida
  defp has_valid_person_info?(params) do
    is_map(params) &&
    params["full_name"] &&
    params["full_name"] != ""
  end

  @doc """
  Returns the list of parent categories.
  """
  def list_parent_categories do
    Category
    |> where([c], c.father == true)
    |> Repo.all()
  end

  @doc """
  Returns the list of child categories for a specific parent category.
  """
  def list_categories_by_parent(parent_id) do
    Category
    |> where([c], c.father_id == ^parent_id)
    |> Repo.all()
    |> Repo.preload(:parent_category)
  end

  @doc """
  Returns the list of categories that can be assigned to judges.
  These are categories that are not parent categories.
  """
  def list_assignable_categories do
    Category
    |> where([c], c.father == false)
    |> Repo.all()
    |> Repo.preload(:parent_category)
  end

  @doc """
  Lists all participants from categories that belong to a specific parent category.
  """
  def list_participants_by_parent_category(parent_id) do
    # Get all child category IDs for this parent
    child_category_ids =
      Category
      |> where([c], c.father_id == ^parent_id)
      |> select([c], c.id)
      |> Repo.all()

    # Get all participants from these categories
    Participant
    |> where([p], p.category_id in ^child_category_ids)
    |> Repo.all()
    |> Repo.preload(:category)
  end

  @doc """
  Calculate aggregated results for all categories under a parent category.
  """
  def calculate_parent_category_results(parent_id) do
    # Get all participants for this parent category
    participants = list_participants_by_parent_category(parent_id)

    # Group participants by their category
    participants_by_category = Enum.group_by(participants, fn p -> p.category_id end)

    # For each category, calculate results
    results = Enum.flat_map(participants_by_category, fn {category_id, category_participants} ->
      category = get_category!(category_id)

      # Get judges and criteria for this category
      judges = list_judges_by_category(category_id)
      criteria = Talent.Scoring.list_root_scoring_criteria_by_category(category_id)

      # Calculate results for each participant in this category
      Enum.map(category_participants, fn participant ->
        total_score = Talent.Scoring.calculate_total_score(participant.id)

        # Calculate scores by judge
        judge_scores = Enum.map(judges, fn judge ->
          scores = Talent.Scoring.get_judge_scores_for_participant(judge.id, participant.id)

          judge_total = Enum.reduce(scores, 0, fn score, acc ->
            if score.criterion && score.criterion.is_discount do
              acc - score.value
            else
              acc + score.value
            end
          end)

          {judge.id, judge_total}
        end) |> Map.new()

        # Calculate scores by criterion
        criteria_scores = Enum.map(criteria, fn criterion ->
          avg_score = Talent.Scoring.calculate_average_score_by_criterion(participant.id, criterion.id)
          {criterion.id, avg_score}
        end) |> Map.new()

        # Return result with the participant's category
        %{
          participant: participant,
          category: category,
          total_score: total_score,
          judge_scores: judge_scores,
          criteria_scores: criteria_scores
        }
      end)
    end)

    # Sort all results by total score
    Enum.sort_by(results, fn result -> result.total_score end, :desc)
  end
end
