defmodule TalentWeb.ParticipantLive.Index do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Competitions.Participant
  alias Talent.Repo

  @impl true
  def mount(_params, _session, socket) do
    categories = Competitions.list_categories() |> Enum.map(fn c -> {c.name, c.id} end)

    # Mapa de categorías para búsqueda rápida
    categories_map = Competitions.list_categories() |> Enum.into(%{}, fn c -> {c.id, c} end)

    # Obtener participantes, sin precargar
    participants = Competitions.list_participants() |> Repo.preload(:person)

    # Añadir información de categoría manualmente a cada participante
    participants_with_categories = Enum.map(participants, fn p ->
      # Obtener el nombre de la categoría si existe
      category_name = if p.category_id, do: categories_map[p.category_id].name, else: "Sin categoría"
      # Crear un mapa con la información de categoría
      Map.put(p, :category_name, category_name)
    end)

    {:ok, socket
      |> stream(:participants, participants_with_categories)
      |> assign(:categories, categories)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Participante")
    |> assign(:participant, Competitions.get_participant!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nuevo Participante")
    |> assign(:participant, %Participant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Participantes")
    |> assign(:participant, nil)
  end

  @impl true
  def handle_info({TalentWeb.ParticipantLive.FormComponent, {:saved, participant}}, socket) do
    # Obtener todas las categorías para buscar el nombre
    categories_map = Competitions.list_categories() |> Enum.into(%{}, fn c -> {c.id, c} end)

    participant_with_person = Repo.preload(participant, :person)

    # Agregar el campo category_name al participante guardado
    participant_with_category =
      if participant.category_id do
        Map.put(participant_with_person, :category_name, categories_map[participant.category_id].name)
      else
        Map.put(participant_with_person, :category_name, "Sin categoría")
      end

    {:noreply, stream_insert(socket, :participants, participant_with_category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    participant = Competitions.get_participant!(id)
    {:ok, _} = Competitions.delete_participant(participant)

    {:noreply, stream_delete(socket, :participants, participant)}
  end
end
