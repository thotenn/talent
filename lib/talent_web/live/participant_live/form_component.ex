defmodule TalentWeb.ParticipantLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Competitions
  alias Talent.Directory
  alias TalentWeb.Components.PersonForm

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
        <PersonForm.person_form_fields person={@participant.person} field_name="person_data" />

        <div class="mt-6" id="networks-container" phx-update="ignore">
          <!-- Aquí van las redes sociales actuales y el formulario para añadir nuevas -->
          <div id="current-networks">
            <!-- Se mostrarán las redes actuales -->
          </div>

          <div class="flex items-end gap-4 mt-4">
            <div class="w-1/3">
              <label class="block text-sm font-medium text-gray-700">Red Social</label>
              <select id="new_network_id" name="new_network_id" class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md">
                <option value="">Seleccione una red social</option>
                <%= for {name, id} <- @networks do %>
                  <option value={id}><%= name %></option>
                <% end %>
              </select>
            </div>
            <div class="w-1/3">
              <label class="block text-sm font-medium text-gray-700">Nombre de Usuario</label>
              <input
                type="text"
                id="new_username"
                name="new_username"
                placeholder="@username"
                class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
              />
            </div>
            <div class="flex-shrink-0">
              <button
                type="button"
                phx-click="add-network"
                phx-target={@myself}
                class="inline-flex h-10 items-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Añadir Red
              </button>
            </div>
          </div>
        </div>

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

    # Inicializar person_data para el formulario si no existe
    if !Map.has_key?(changeset.params || %{}, "person_data") do
      changeset =
        if participant.person do
          # Si hay una persona asociada, inicializar con sus datos
          person_data = %{
            "full_name" => participant.person.full_name,
            "short_name" => participant.person.short_name,
            "phone" => participant.person.phone,
            "identity_number" => participant.person.identity_number,
            "birth_date" => participant.person.birth_date,
            "gender" => participant.person.gender,
            "extra_data" => participant.person.extra_data
          }

          # Si hay redes sociales, añadirlas
          networks_data = if Ecto.assoc_loaded?(participant.person.person_networks) do
            Enum.map(participant.person.person_networks, fn pn ->
              %{
                "network_id" => pn.network_id,
                "username" => pn.username
              }
            end)
          else
            []
          end

          # Añadir networks_data si hay redes sociales
          person_data = if length(networks_data) > 0 do
            Map.put(person_data, "networks_data", networks_data)
          else
            person_data
          end

          # Actualizar el changeset con person_data
          put_in(changeset.params["person_data"], person_data)
        else
          # Si no hay persona, inicializar vacío
          put_in(changeset.params["person_data"], %{})
        end
    end

    # Obtener la lista de redes para el select
    networks = Directory.list_networks() |> Enum.map(fn n -> {n.name, n.id} end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:participant, participant)
     |> assign(:networks, networks)
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

  def handle_event("add-network", _params, socket) do
    # Obtener los valores de los inputs
    network_id = socket.assigns.myself
                |> JS.exec("input#new_network_id", :getAttribute, ["value"])
                |> JS.exec("getValue")

    username = socket.assigns.myself
              |> JS.exec("input#new_username", :getAttribute, ["value"])
              |> JS.exec("getValue")

    # Solo proceder si ambos valores están presentes
    if network_id && username && network_id != "" && username != "" do
      # Preparar la nueva entrada
      new_network = %{
        "network_id" => network_id,
        "username" => username
      }

      # Obtener la lista actual de redes (o inicializarla)
      current_params = socket.assigns.form.params || %{}
      person_data = current_params["person_data"] || %{}
      networks_data = person_data["networks_data"] || []

      # Añadir la nueva red
      updated_networks = networks_data ++ [new_network]

      # Actualizar la estructura de params
      updated_person_data = Map.put(person_data, "networks_data", updated_networks)
      updated_params = Map.put(current_params, "person_data", updated_person_data)

      # Reconstruir el changeset con los parámetros actualizados
      changeset = Competitions.change_participant(socket.assigns.participant, updated_params)

      # Actualizar el formulario
      {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    else
      # Si faltan datos, no hacer nada
      {:noreply, socket}
    end
  end

  def handle_event("remove-network", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)

    # Obtener la lista actual de redes
    current_params = socket.assigns.form.params || %{}
    person_data = current_params["person_data"] || %{}
    networks_data = person_data["networks_data"] || []

    # Eliminar la red en el índice especificado
    updated_networks = List.delete_at(networks_data, index)

    # Actualizar la estructura de params
    updated_person_data = Map.put(person_data, "networks_data", updated_networks)
    updated_params = Map.put(current_params, "person_data", updated_person_data)

    # Reconstruir el changeset con los parámetros actualizados
    changeset = Competitions.change_participant(socket.assigns.participant, updated_params)

    # Actualizar el formulario
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
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
