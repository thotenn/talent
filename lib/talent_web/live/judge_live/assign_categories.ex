defmodule TalentWeb.JudgeLive.AssignCategories do
  use TalentWeb, :live_view

  alias Talent.Competitions
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
end
