defmodule TalentWeb.ParticipantLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Competitions
  alias Talent.Accounts.PersonInfo
  alias Talent.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-lg font-medium mb-4"><%= @title %></h2>

      <form
        id="participant-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nombre" />
        <.input field={@form[:category_id]} type="select" label="Categoría" options={@categories} />

        <div class="border-t border-gray-300 my-6 pt-6">
          <.live_component
            module={TalentWeb.PersonInfoLive.FormComponent}
            id="person-info-form"
            person_info={@person_info}
            title="Información Personal"
          />
        </div>

        <div class="mt-6">
          <.button type="submit" phx-disable-with="Guardando...">Guardar Participante</.button>
        </div>
      </form>
    </div>
    """
  end

  @impl true
  def update(%{participant: participant} = assigns, socket) do
    changeset = Competitions.change_participant(participant)

    # Asegurarnos de precargar la relación con person
    participant = if Ecto.assoc_loaded?(participant.person),
                     do: participant,
                     else: Repo.preload(participant, :person)

    # Cargar o crear la información personal relacionada
    person_info = if participant.person_id do
      # Obtener la persona existente
      Talent.Accounts.get_person_info!(participant.person_id)
    else
      # Crear una nueva persona vacía
      %Talent.Accounts.PersonInfo{}
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:person_info, person_info)
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

  def handle_event("save", params, socket) do
    participant_params = Map.get(params, "participant", %{})
    person_info_params = Map.get(params, "person_info", %{})
    networks_params = Map.get(params, "networks", %{})

    save_participant(socket, socket.assigns.action, participant_params, person_info_params, networks_params)
  end

  defp save_participant(socket, :edit, participant_params, person_info_params, networks_params) do
    IO.inspect(socket.assigns.participant, label: "Participante original")
    IO.inspect(person_info_params, label: "Parámetros de información personal")

    case Competitions.update_participant_with_person_info(
      socket.assigns.participant,
      participant_params,
      person_info_params,
      networks_params
    ) do
      {:ok, %{participant: participant}} ->
        IO.inspect(participant, label: "Participante actualizado")

        # Precargar todas las relaciones necesarias
        participant =
          if is_nil(participant.person) && not is_nil(participant.person_id) do
            # Precargar la relación si no está cargada
            Repo.preload(participant, :person)
          else
            participant
          end

        # Mostrar el resultado final para verificar
        IO.inspect(participant, label: "Participante actualizado con persona")

        notify_parent({:saved, participant})

        {:noreply,
         socket
         |> put_flash(:info, "Participante actualizado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, :participant, changeset, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error al actualizar el participante")
         |> assign_form(changeset)}

      {:error, :person_info, _changeset, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error al actualizar la información personal")
         |> assign_form(Competitions.change_participant(socket.assigns.participant, participant_params))}

      error ->
        IO.inspect(error, label: "Error inesperado")
        {:noreply,
         socket
         |> put_flash(:error, "Error inesperado")
         |> assign_form(Competitions.change_participant(socket.assigns.participant, participant_params))}
    end
  end

  defp save_participant(socket, :new, participant_params, person_info_params, networks_params) do
    case Competitions.create_participant_with_person_info(
      participant_params,
      person_info_params,
      networks_params
    ) do
      {:ok, %{participant: participant}} ->
        # Precargar el participante con todas sus relaciones
        participant = Repo.preload(participant, [:category, :person])

        notify_parent({:saved, participant})

        {:noreply,
         socket
         |> put_flash(:info, "Participante creado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, :participant, changeset, _} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, :person_info, _changeset, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error al guardar la información personal")
         |> assign_form(Competitions.change_participant(%Talent.Competitions.Participant{}, participant_params))}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
