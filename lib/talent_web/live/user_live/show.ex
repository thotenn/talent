defmodule TalentWeb.UserLive.Show do
  use TalentWeb, :live_view

  alias Talent.Accounts
  import TalentWeb.Components.PersonDetail

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # Precargar la persona con sus redes sociales
    user = Accounts.get_user_with_person!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, user)}
  end

  defp page_title(:show), do: "Mostrar Usuario"
  defp page_title(:edit), do: "Editar Usuario"
end
