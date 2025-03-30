defmodule TalentWeb.NetworkLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Directory

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Configure las redes sociales disponibles para los perfiles</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="network-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nombre" required />
        <.input field={@form[:base_url]} type="url" label="URL Base" required placeholder="https://facebook.com/" />

        <:actions>
          <.button phx-disable-with="Guardando...">Guardar Red Social</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{network: network} = assigns, socket) do
    changeset = Directory.change_network(network)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"network" => network_params}, socket) do
    changeset =
      socket.assigns.network
      |> Directory.change_network(network_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"network" => network_params}, socket) do
    save_network(socket, socket.assigns.action, network_params)
  end

  defp save_network(socket, :edit, network_params) do
    case Directory.update_network(socket.assigns.network, network_params) do
      {:ok, network} ->
        notify_parent({:saved, network})

        {:noreply,
         socket
         |> put_flash(:info, "Red social actualizada exitosamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_network(socket, :new, network_params) do
    case Directory.create_network(network_params) do
      {:ok, network} ->
        notify_parent({:saved, network})

        {:noreply,
         socket
         |> put_flash(:info, "Red social creada exitosamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
