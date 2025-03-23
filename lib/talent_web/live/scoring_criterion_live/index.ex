defmodule TalentWeb.ScoringCriterionLive.Index do
  use TalentWeb, :live_view

  alias Talent.Scoring
  alias Talent.Scoring.ScoringCriterion
  alias Talent.Competitions
  alias Talent.Repo

  @impl true
  def mount(_params, _session, socket) do
    # Cargar los criterios con las relaciones necesarias
    criteria = Scoring.list_scoring_criteria()

    # Obtener categorías para el formulario
    categories = Competitions.list_categories() |> Enum.map(fn c -> {c.name, c.id} end)

    {:ok, socket
      |> stream(:scoring_criteria, criteria, reset: true)
      |> assign(:categories, categories)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Criterio de Puntuación")
    |> assign(:criterion, Scoring.get_scoring_criterion!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nuevo Criterio de Puntuación")
    |> assign(:criterion, %ScoringCriterion{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Criterios de Puntuación")
    |> assign(:criterion, nil)
  end

  @impl true
  def handle_info({TalentWeb.ScoringCriterionLive.FormComponent, {:saved, criterion}}, socket) do
    # Asegurarnos de que el criterio tiene todas sus relaciones cargadas
    criterion = Repo.preload(criterion, [:categories, :parent, :sub_criteria])

    # Insertar el criterio actualizado en el stream
    {:noreply, stream_insert(socket, :scoring_criteria, criterion)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    criterion = Scoring.get_scoring_criterion!(id)

    # Intenta eliminar el criterio
    case Scoring.delete_scoring_criterion(criterion) do
      {:ok, _} ->
        # La eliminación fue exitosa
        {:noreply, stream_delete(socket, :scoring_criteria, criterion)}

      {:error, _} ->
        # Hubo un error, recarga los datos
        {:noreply,
        socket
        |> put_flash(:error, "No se puede eliminar este criterio porque tiene subcriterios o puntuaciones asociadas.")
        |> stream(:scoring_criteria, Scoring.list_scoring_criteria(), reset: true)
        }
    end
  end
end
