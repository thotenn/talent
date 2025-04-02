defmodule TalentWeb.UserLive.Show do
  use TalentWeb, :live_view

  alias Talent.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = Accounts.get_user!(id) |> Talent.Repo.preload([person: :person_networks])

    # Si el usuario tiene información personal, cargar las redes sociales
    networks = if user.person do
      user.person.person_networks |> Talent.Repo.preload(:network)
    else
      []
    end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, user)
     |> assign(:networks, networks)}
  end

  defp page_title(:show), do: "Detalles de Usuario"
  defp page_title(:edit), do: "Editar Usuario"
end
