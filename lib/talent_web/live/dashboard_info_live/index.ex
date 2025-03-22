defmodule TalentWeb.DashboardInfoLive.Index do
  use TalentWeb, :live_view

  alias Talent.Dashboard
  alias Talent.Dashboard.DashboardInfo

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    {:ok, assign(socket,
      page_title: "Dashboard",
      user_role: current_user.role
    )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Dashboard info")
    |> assign(:dashboard_info, Dashboard.get_dashboard_info!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Dashboard info")
    |> assign(:dashboard_info, %DashboardInfo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Dashboard infos")
    |> assign(:dashboard_info, nil)
  end

  @impl true
  def handle_info({TalentWeb.DashboardInfoLive.FormComponent, {:saved, dashboard_info}}, socket) do
    {:noreply, stream_insert(socket, :dashboard_infos, dashboard_info)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dashboard_info = Dashboard.get_dashboard_info!(id)
    {:ok, _} = Dashboard.delete_dashboard_info(dashboard_info)

    {:noreply, stream_delete(socket, :dashboard_infos, dashboard_info)}
  end
end
