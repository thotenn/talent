defmodule Talent.Competitions do
  @moduledoc """
  The Competitions context.
  """

  import Ecto.Query, warn: false
  alias Talent.Repo

  alias Talent.Competitions.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
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
  Creates a participant with person information if provided.
  """
  def create_participant_with_person(attrs \\ %{}) do
    Repo.transaction(fn ->
      # Extraer datos de persona si están presentes
      person_data = Map.get(attrs, "person_data") || Map.get(attrs, :person_data)

      # Crear primero el participante
      case create_participant(attrs) do
        {:ok, participant} ->
          # Si hay datos de persona, crear o actualizar la persona
          if is_map(person_data) && map_size(person_data) > 0 do
            # Crear nueva persona
            case Talent.Directory.create_person_info(person_data) do
              {:ok, person} ->
                # Asociar la persona al participante
                {:ok, updated_participant} = update_participant(participant, %{person_id: person.id})
                updated_participant
              {:error, changeset} ->
                Repo.rollback(changeset)
            end
          else
            participant
          end

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a participant with person information if provided.
  """
  def update_participant_with_person(%Participant{} = participant, attrs) do
    Repo.transaction(fn ->
      # Extraer datos de persona si están presentes
      person_data = Map.get(attrs, "person_data") || Map.get(attrs, :person_data)

      # Actualizar primero el participante
      case update_participant(participant, attrs) do
        {:ok, updated_participant} ->
          # Si hay datos de persona, crear o actualizar la persona
          if is_map(person_data) && map_size(person_data) > 0 do
            # Verificar si ya hay una persona asociada
            if updated_participant.person_id do
              # Actualizar persona existente
              person = Talent.Directory.get_person_info!(updated_participant.person_id)
              {:ok, _updated_person} = Talent.Directory.update_person_info(person, person_data)
            else
              # Crear nueva persona
              case Talent.Directory.create_person_info(person_data) do
                {:ok, person} ->
                  # Asociar la persona al participante
                  {:ok, participant_with_person} = update_participant(updated_participant, %{person_id: person.id})
                  participant_with_person
                {:error, changeset} ->
                  Repo.rollback(changeset)
              end
            end
          else
            updated_participant
          end

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Gets a participant with preloaded person information.
  """
  def get_participant_with_person!(id) do
    Participant
    |> Repo.get!(id)
    |> Repo.preload([:category, person: [person_networks: :network]])
  end

  @doc """
  Lists participants with preloaded person information.
  """
  def list_participants_with_person do
    Participant
    |> Repo.all()
    |> Repo.preload([:category, person: [person_networks: :network]])
  end
end
