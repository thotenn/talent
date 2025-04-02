defmodule TalentWeb.PersonInfoLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Accounts
  alias Talent.Accounts.PersonInfo

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-target={@myself}>
      <h2 class="text-lg font-semibold mb-4"><%= @title || "Información Personal" %></h2>

      <div class="bg-white rounded-lg">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <.input field={@form[:full_name]} type="text" label="Nombre Completo" required name="person_info[full_name]" />
          </div>
          <div>
            <.input field={@form[:short_name]} type="text" label="Nombre Corto" placeholder="Como te gustaría que te llamen" name="person_info[short_name]" />
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
          <div>
            <.input field={@form[:phone]} type="tel" label="Teléfono" name="person_info[phone]" />
          </div>
          <div>
            <.input field={@form[:identity_number]} type="text" label="Número de Identidad" placeholder="DNI, Cédula, etc." name="person_info[identity_number]" />
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
          <div>
            <.input field={@form[:birth_date]} type="date" label="Fecha de Nacimiento" name="person_info[birth_date]" />
          </div>
          <div>
            <.input
              field={@form[:gender]}
              type="select"
              label="Género"
              options={Enum.map(PersonInfo.gender_options(), fn opt -> {opt, opt} end)}
              prompt="Seleccionar género"
              name="person_info[gender]"
            />
          </div>
        </div>

        <div class="mt-4">
          <.input field={@form[:extra_data]} type="textarea" label="Información Adicional" rows="3" name="person_info[extra_data]" />
        </div>
      </div>

      <div class="mt-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-lg font-semibold">Redes Sociales</h2>
          <button
            type="button"
            phx-click="add-network"
            phx-target={@myself}
            class="bg-green-600 hover:bg-green-700 text-white py-1 px-3 rounded text-sm"
          >
            + Añadir Red
          </button>
        </div>

        <%= if @networks == [] do %>
          <p class="text-gray-500 italic mb-4">No hay redes sociales registradas.</p>
        <% end %>

        <div id="networks-container">
          <%= for {network, i} <- Enum.with_index(@networks) do %>
            <div
              id={"network-#{i}"}
              class="border border-gray-200 rounded p-4 mb-4 relative"
              phx-hook="NetworkFormFields"
              data-index={i}
            >
              <button
                type="button"
                phx-click="remove-network"
                phx-value-index={i}
                phx-target={@myself}
                class="absolute top-2 right-2 text-red-600 hover:text-red-800"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
              </button>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Red Social</label>
                  <select
                    name={"networks[#{i}][network_id]"}
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-0 sm:text-sm"
                    value={network.network_id}
                  >
                    <option value="">Seleccionar red social</option>
                    <%= for {name, id} <- @network_options do %>
                      <option value={id} selected={to_string(network.network_id) == to_string(id)}><%= name %></option>
                    <% end %>
                  </select>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Usuario</label>
                  <input
                    type="text"
                    name={"networks[#{i}][username]"}
                    value={network.username}
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-0 sm:text-sm"
                  />
                </div>
              </div>

              <div class="mt-2">
                <label class="block text-sm font-medium text-gray-700 mb-1">URL</label>
                <input
                  type="text"
                  name={"networks[#{i}][url]"}
                  value={network.url}
                  placeholder="Se generará automáticamente si no se especifica"
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-0 sm:text-sm"
                />
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{person_info: person_info} = assigns, socket) do
    # Obtener las redes existentes o inicializar una lista vacía
    networks = if person_info.id do
      # Si es una edición, cargar las redes existentes
      person_info = Talent.Repo.preload(person_info, [person_networks: [:network]])

      Enum.map(person_info.person_networks || [], fn pn ->
        %{
          id: pn.id,
          network_id: pn.network_id,
          username: pn.username || "",
          url: pn.url || ""
        }
      end)
    else
      # Si es creación, inicializar una lista vacía
      []
    end

    # Si ya hay redes en el socket, usarlas en lugar de las cargadas
    networks = if socket.assigns[:networks], do: socket.assigns.networks, else: networks

    # Obtener todas las redes disponibles para el dropdown
    network_options = Accounts.list_networks() |> Enum.map(fn n -> {n.name, n.id} end)

    # Crear el changeset con los datos existentes
    changeset = PersonInfo.changeset(person_info, %{
      full_name: person_info.full_name,
      short_name: person_info.short_name,
      phone: person_info.phone,
      identity_number: person_info.identity_number,
      birth_date: person_info.birth_date,
      gender: person_info.gender,
      extra_data: person_info.extra_data
    })

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:networks, networks)
     |> assign(:network_options, network_options)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("add-network", _params, socket) do
    # Obtener redes actuales
    current_networks = socket.assigns.networks

    # Añadir una nueva red vacía
    networks = current_networks ++ [%{id: nil, network_id: nil, username: "", url: ""}]

    {:noreply, assign(socket, :networks, networks)}
  end

  @impl true
  def handle_event("remove-network", %{"index" => index_string}, socket) do
    index = String.to_integer(index_string)

    # Obtener redes actuales
    current_networks = socket.assigns.networks

    # Eliminar la red en el índice especificado
    networks = List.delete_at(current_networks, index)

    {:noreply, assign(socket, :networks, networks)}
  end

  @impl true
  def handle_event("update-network", %{"index" => index, "data" => data}, socket) do
    index =
      case index do
        idx when is_binary(idx) -> String.to_integer(idx)
        idx when is_integer(idx) -> idx
      end

    # Convertir network_id a entero si es posible
    network_id =
      case data["network_id"] do
        id when id in ["", nil] -> nil
        id ->
          case Integer.parse(id) do
            {num, _} -> num
            :error -> id
          end
      end

    # Actualizar la red específica
    updated_networks =
      List.update_at(socket.assigns.networks, index, fn network ->
        %{
          id: network.id,
          network_id: network_id,
          username: data["username"],
          url: data["url"]
        }
      end)

    {:noreply, assign(socket, :networks, updated_networks)}
  end
end
