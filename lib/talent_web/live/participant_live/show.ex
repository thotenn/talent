defmodule TalentWeb.ParticipantLive.Show do
  use TalentWeb, :live_view

  alias Talent.Competitions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:participant, Competitions.get_participant!(id))}
  end

  defp page_title(:show), do: "Mostrar Participante"
  defp page_title(:edit), do: "Editar Participante"
end
