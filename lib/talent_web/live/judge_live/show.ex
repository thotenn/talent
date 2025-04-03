defmodule TalentWeb.JudgeLive.Show do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    judge = Competitions.get_judge!(id) |> Repo.preload([:user, :categories])

    # Obtener todas las categorías disponibles - ahora solo las que NO son categorías padre
    categories = Competitions.list_assignable_categories()

    # Crear un mapa para rastrear qué categorías están asignadas al juez
    assigned_categories = Enum.into(judge.categories, %{}, fn cat -> {cat.id, true} end)

    {:ok, socket
      |> assign(:judge, judge)
      |> assign(:categories, categories)
      |> assign(:assigned_categories, assigned_categories)
      |> assign(:page_title, "Detalles del Juez: #{judge.name}")
    }
  end

  @impl true
  def handle_event("toggle_category", %{"category-id" => category_id}, socket) do
    judge = socket.assigns.judge
    category_id = String.to_integer(category_id)

    # Verificar si la categoría ya está asignada
    is_assigned = Map.get(socket.assigns.assigned_categories, category_id, false)

    # Asignar o desasignar según corresponda
    if is_assigned do
      Competitions.unassign_judge_from_category(judge.id, category_id)
    else
      Competitions.assign_judge_to_category(judge.id, category_id)
    end

    # Actualizar el juez y las categorías asignadas
    updated_judge = Competitions.get_judge!(judge.id) |> Repo.preload(:categories)
    updated_assigned_categories = Enum.into(updated_judge.categories, %{}, fn cat -> {cat.id, true} end)

    {:noreply, socket
      |> assign(:judge, updated_judge)
      |> assign(:assigned_categories, updated_assigned_categories)
    }
  end
end
