defmodule TalentWeb.ParticipantLive.Show do
  use TalentWeb, :live_view

  alias Talent.Competitions
  import TalentWeb.Components.PersonDetail

  @impl true
  def mount(_params, _session, socket) do
    categories = Competitions.list_categories() |> Enum.map(fn c -> {c.name, c.id} end)
    {:ok, socket |> assign(:categories, categories)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # Precargar la persona con sus redes sociales
    participant = Competitions.get_participant_with_person!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:participant, participant)}
  end

  defp page_title(:show), do: "Mostrar Participante"
  defp page_title(:edit), do: "Editar Participante"
end
