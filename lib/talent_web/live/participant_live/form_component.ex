defmodule TalentWeb.ParticipantLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Competitions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-lg font-medium mb-4"><%= @title %></h2>

      <.form
        for={@form}
        id="participant-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nombre" />
        <.input field={@form[:category_id]} type="select" label="Categoría" options={@categories} />

        <div class="mt-6">
          <.button phx-disable-with="Guardando...">Guardar Participante</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{participant: participant} = assigns, socket) do
    changeset = Competitions.change_participant(participant)

    {:ok,
     socket
     |> assign(assigns)
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

  defp save_participant(socket, :edit, participant_params) do
    case Competitions.update_participant(socket.assigns.participant, participant_params) do
      {:ok, participant} ->
        participant = Competitions.get_participant!(participant.id)
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
    case Competitions.create_participant(participant_params) do
      {:ok, participant} ->
        participant = Competitions.get_participant!(participant.id)
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
