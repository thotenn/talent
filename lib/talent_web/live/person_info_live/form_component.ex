defmodule TalentWeb.PersonInfoLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Accounts
  alias Talent.Accounts.PersonInfo
  alias Talent.Accounts.PersonNetwork

  @impl true
  def render(assigns) do
    ~H"""
    <div>
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
            phx-target={@myself}
            phx-click="add-network"
            class="bg-green-600 hover:bg-green-700 text-white py-1 px-3 rounded text-sm"
          >
            + Añadir Red
          </button>
        </div>

        <%= if @networks == [] do %>
          <p class="text-gray-500 italic mb-4">No hay redes sociales registradas.</p>
        <% end %>

        <%= for {network, i} <- Enum.with_index(@networks) do %>
          <div class="border border-gray-200 rounded p-4 mb-4 relative">
            <button
              type="button"
              phx-target={@myself}
              phx-click="remove-network"
              phx-value-index={i}
              class="absolute top-2 right-2 text-red-600 hover:text-red-800"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <.input
                  field={@network_fields[i].network_id}
                  type="select"
                  label="Red Social"
                  options={@network_options}
                  prompt="Seleccionar red social"
                  name={"networks[#{i}][network_id]"}
                  value={network.network_id}
                />
              </div>
              <div>
                <.input
                  field={@network_fields[i].username}
                  type="text"
                  label="Usuario"
                  name={"networks[#{i}][username]"}
                  value={network.username}
                />
              </div>
            </div>

            <div class="mt-2">
              <.input
                field={@network_fields[i].url}
                type="text"
                label="URL"
                placeholder="Se generará automáticamente si no se especifica"
                name={"networks[#{i}][url]"}
                value={network.url}
              />
            </div>
          </div>
        <% end %>
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

    # Crear campos para las redes sociales
    network_fields = create_network_fields(networks)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:networks, networks)
     |> assign(:network_options, network_options)
     |> assign(:network_fields, network_fields)
     |> assign(:form, to_form(changeset))}
  end

  # Crea los campos para las redes sociales
  defp create_network_fields(networks) do
    Enum.with_index(networks)
    |> Enum.map(fn {network, i} ->
      network_id_form = to_form(%{"value" => network.network_id})
      username_form = to_form(%{"value" => network.username})
      url_form = to_form(%{"value" => network.url})

      {i, %{
        network_id: network_id_form[:value],
        username: username_form[:value],
        url: url_form[:value]
      }}
    end)
    |> Map.new()
  end

  @impl true
  def handle_event("add-network", params, socket) do
    # Obtener y preservar los valores actuales de las redes existentes
    updated_networks =
      socket.assigns.networks
      |> Enum.with_index()
      |> Enum.map(fn {network, i} ->
        network_id = params["networks"] && params["networks"]["#{i}"] && params["networks"]["#{i}"]["network_id"]
        username = params["networks"] && params["networks"]["#{i}"] && params["networks"]["#{i}"]["username"]
        url = params["networks"] && params["networks"]["#{i}"] && params["networks"]["#{i}"]["url"]

        %{
          id: network.id,
          network_id: parse_integer_or_default(network_id, network.network_id),
          username: username || network.username || "",
          url: url || network.url || ""
        }
      end)

    # Añadir la nueva red
    networks = updated_networks ++ [%{id: nil, network_id: nil, username: "", url: ""}]

    # Actualizar los campos para todas las redes
    network_fields = create_network_fields(networks)

    {:noreply,
     socket
     |> assign(:networks, networks)
     |> assign(:network_fields, network_fields)}
  end

  @impl true
  def handle_event("remove-network", %{"index" => index_string} = params, socket) do
    index = String.to_integer(index_string)

    # Obtener y preservar los valores actuales de las redes
    current_networks =
      socket.assigns.networks
      |> Enum.with_index()
      |> Enum.map(fn {network, i} ->
        network_id = params["networks"] && params["networks"]["#{i}"] && params["networks"]["#{i}"]["network_id"]
        username = params["networks"] && params["networks"]["#{i}"] && params["networks"]["#{i}"]["username"]
        url = params["networks"] && params["networks"]["#{i}"] && params["networks"]["#{i}"]["url"]

        %{
          id: network.id,
          network_id: parse_integer_or_default(network_id, network.network_id),
          username: username || network.username || "",
          url: url || network.url || ""
        }
      end)

    # Eliminar la red en el índice especificado
    networks = List.delete_at(current_networks, index)

    # Actualizar los campos para las redes restantes
    network_fields = create_network_fields(networks)

    {:noreply,
     socket
     |> assign(:networks, networks)
     |> assign(:network_fields, network_fields)}
  end

  # Funciones auxiliares

  # Parsea un string a integer, devolviendo un valor por defecto si falla
  defp parse_integer_or_default(nil, default), do: default
  defp parse_integer_or_default("", default), do: default
  defp parse_integer_or_default(string, default) when is_binary(string) do
    case Integer.parse(string) do
      {number, _} -> number
      :error -> default
    end
  end
  defp parse_integer_or_default(value, _default) when is_integer(value), do: value
  defp parse_integer_or_default(_, default), do: default
end
