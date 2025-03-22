defmodule TalentWeb.CategoryLive.Show do
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
     |> assign(:category, Competitions.get_category!(id))}
  end

  defp page_title(:show), do: "Ver Categoría"
  defp page_title(:edit), do: "Editar Categoría"
end
