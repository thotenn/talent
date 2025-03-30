defmodule TalentWeb.ParticipantLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Competitions
  import TalentWeb.Components.PersonForm

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="participant-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nombre" />
        <.input field={@form[:category_id]} type="select" label="Categoría" options={@categories} />

        <!-- Información personal -->
        <.person_form_fields person={@participant.person} field_name="person_data" />

        <div class="mt-6">
          <.button phx-disable-with="Guardando...">Guardar Participante</.button>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{participant: participant} = assigns, socket) do
    # Asegurarnos de que precarguemos la persona y sus redes sociales si existe
    participant = cond do
      is_nil(participant) ->
        %Talent.Competitions.Participant{}
      is_nil(participant.id) ->
        participant
      true ->
        # Precargamos explícitamente la persona y sus redes
        Competitions.get_participant_with_person!(participant.id)
    end

    changeset = Competitions.change_participant(participant)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:participant, participant)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"participant" => participant_params}, socket) do
    changeset =
      socket.assigns.participant
      |> Competitions.change_participant(participant_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"participant" => participant_params}, socket) do
    save_participant(socket, socket.assigns.action, participant_params)
  end

  # Manejar eventos para añadir/eliminar redes sociales
  def handle_event("add-network", %{"new_network_id" => network_id, "new_username" => username}, socket) when network_id != "" and username != "" do
    # Añadimos la nueva red al formulario
    networks_data = socket.assigns.form[:person_data][:networks_data] || []
    new_network = %{
      "network_id" => network_id,
      "username" => username
    }

    updated_networks = networks_data ++ [new_network]

    # Actualizar el form
    updated_form = socket.assigns.form
      |> Map.put(:person_data, Map.put(socket.assigns.form.person_data, :networks_data, updated_networks))

    {:noreply, assign(socket, form: updated_form)}
  end

  def handle_event("add-network", _params, socket) do
    # Datos incompletos, ignoramos
    {:noreply, socket}
  end

  def handle_event("remove-network", %{"index" => index}, socket) do
    index = String.to_integer(index)
    networks_data = socket.assigns.form[:person_data][:networks_data] || []

    # Eliminar la red en el índice especificado
    updated_networks = List.delete_at(networks_data, index)

    # Actualizar el form
    updated_form = socket.assigns.form
      |> Map.put(:person_data, Map.put(socket.assigns.form.person_data, :networks_data, updated_networks))

    {:noreply, assign(socket, form: updated_form)}
  end

  defp save_participant(socket, :edit, participant_params) do
    case Competitions.update_participant_with_person(socket.assigns.participant, participant_params) do
      {:ok, participant} ->
        notify_parent({:saved, participant})

        {:noreply,
         socket
         |> put_flash(:info, "Participante actualizado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_participant(socket, :new, participant_params) do
    case Competitions.create_participant_with_person(participant_params) do
      {:ok, participant} ->
        notify_parent({:saved, participant})

        {:noreply,
         socket
         |> put_flash(:info, "Participante creado correctamente")
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
