defmodule TalentWeb.DashboardInfoLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Dashboard

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage dashboard_info records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="dashboard_info-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <:actions>
          <.button phx-disable-with="Saving...">Save Dashboard info</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{dashboard_info: dashboard_info} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Dashboard.change_dashboard_info(dashboard_info))
     end)}
  end

  @impl true
  def handle_event("validate", %{"dashboard_info" => dashboard_info_params}, socket) do
    changeset = Dashboard.change_dashboard_info(socket.assigns.dashboard_info, dashboard_info_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"dashboard_info" => dashboard_info_params}, socket) do
    save_dashboard_info(socket, socket.assigns.action, dashboard_info_params)
  end

  defp save_dashboard_info(socket, :edit, dashboard_info_params) do
    case Dashboard.update_dashboard_info(socket.assigns.dashboard_info, dashboard_info_params) do
      {:ok, dashboard_info} ->
        notify_parent({:saved, dashboard_info})

        {:noreply,
         socket
         |> put_flash(:info, "Dashboard info updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_dashboard_info(socket, :new, dashboard_info_params) do
    case Dashboard.create_dashboard_info(dashboard_info_params) do
      {:ok, dashboard_info} ->
        notify_parent({:saved, dashboard_info})

        {:noreply,
         socket
         |> put_flash(:info, "Dashboard info created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
