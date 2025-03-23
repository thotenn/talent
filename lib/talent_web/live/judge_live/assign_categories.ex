defmodule TalentWeb.JudgeLive.AssignCategories do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Scoring
  alias Talent.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    judge = Competitions.get_judge!(id) |> Repo.preload([:user, :categories])

    # Obtener todas las categorías disponibles
    categories = Competitions.list_categories()

    # Crear un mapa para rastrear qué categorías están asignadas al juez
    assigned_categories = Enum.into(judge.categories, %{}, fn cat -> {cat.id, true} end)

    {:ok, socket
      |> assign(:judge, judge)
      |> assign(:categories, categories)
      |> assign(:assigned_categories, assigned_categories)
      |> assign(:page_title, "Asignar Categorías a #{judge.name}")
      |> assign(:show_criteria_modal, false)
      |> assign(:selected_category, nil)
      |> assign(:criteria_for_category, [])
      |> assign(:assigned_criteria, %{})
    }
  end

  @impl true
  def handle_event("toggle_category", %{"category-id" => category_id}, socket) do
    judge = socket.assigns.judge
    category_id = String.to_integer(category_id)

    # Verificar si la categoría ya está asignada
    is_assigned = Map.get(socket.assigns.assigned_categories, category_id, false)

    # Preparar variables para ambos caminos
    {_result, new_assigned, msg} = if is_assigned do
      # Desasignar categoría
      result = Competitions.unassign_judge_from_category(judge.id, category_id)
      new_assigned = Map.delete(socket.assigns.assigned_categories, category_id)
      {result, new_assigned, "Categoría eliminada del juez"}
    else
      # Asignar categoría
      result = Competitions.assign_judge_to_category(judge.id, category_id)
      new_assigned = Map.put(socket.assigns.assigned_categories, category_id, true)
      {result, new_assigned, "Categoría asignada al juez"}
    end

    {:noreply, socket
      |> assign(:assigned_categories, new_assigned)
      |> put_flash(:info, msg)
    }
  end

  @impl true
  def handle_event("open_criteria_modal", %{"category-id" => category_id}, socket) do
    judge = socket.assigns.judge
    category_id = String.to_integer(category_id)
    category = Enum.find(socket.assigns.categories, &(&1.id == category_id))

    # Obtener todos los criterios para esta categoría
    criteria = Scoring.list_scoring_criteria_by_category(category_id)

    # Crear un mapa para rastrear qué criterios están asignados al juez en esta categoría
    assigned_criteria = get_assigned_criteria_map(judge.id, category_id, criteria)

    {:noreply, socket
      |> assign(:show_criteria_modal, true)
      |> assign(:selected_category, category)
      |> assign(:criteria_for_category, criteria)
      |> assign(:assigned_criteria, assigned_criteria)
    }
  end

  @impl true
  def handle_event("close_criteria_modal", _params, socket) do
    {:noreply, assign(socket, :show_criteria_modal, false)}
  end

  @impl true
  def handle_event("toggle_criterion", %{"criterion-id" => criterion_id, "category-id" => category_id}, socket) do
    judge = socket.assigns.judge
    criterion_id = String.to_integer(criterion_id)
    category_id = String.to_integer(category_id)

    # Verificar si el criterio ya está asignado
    is_assigned = Map.get(socket.assigns.assigned_criteria, criterion_id, false)

    # Asignar o desasignar según corresponda
    {new_assigned, msg} = if is_assigned do
      Scoring.unassign_criterion_from_judge(judge.id, criterion_id, category_id)
      {Map.delete(socket.assigns.assigned_criteria, criterion_id), "Criterio eliminado del juez"}
    else
      Scoring.assign_criterion_to_judge(judge.id, criterion_id, category_id)
      {Map.put(socket.assigns.assigned_criteria, criterion_id, true), "Criterio asignado al juez"}
    end

    {:noreply, socket
      |> assign(:assigned_criteria, new_assigned)
      |> put_flash(:info, msg)
    }
  end

  # Función auxiliar para obtener un mapa de los criterios asignados
  defp get_assigned_criteria_map(judge_id, category_id, criteria) do
    assigned_criteria = Scoring.list_criteria_for_judge_in_category(judge_id, category_id)
    assigned_criteria_ids = Enum.map(assigned_criteria, &(&1.id))

    Enum.into(criteria, %{}, fn criterion ->
      {criterion.id, Enum.member?(assigned_criteria_ids, criterion.id)}
    end)
  end
end
