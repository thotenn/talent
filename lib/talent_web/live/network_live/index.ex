defmodule TalentWeb.NetworkLive.Index do
  use TalentWeb, :live_view

  alias Talent.Directory
  alias Talent.Directory.Network

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
     |> assign(:page_title, "Redes Sociales")
     |> stream(:networks, Directory.list_networks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Red Social")
    |> assign(:network, Directory.get_network!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nueva Red Social")
    |> assign(:network, %Network{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Redes Sociales")
    |> assign(:network, nil)
  end

  @impl true
  def handle_info({TalentWeb.NetworkLive.FormComponent, {:saved, network}}, socket) do
    {:noreply, stream_insert(socket, :networks, network)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    network = Directory.get_network!(id)
    {:ok, _} = Directory.delete_network(network)

    {:noreply, stream_delete(socket, :networks, network)}
  end
end
