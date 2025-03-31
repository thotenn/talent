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
                  field={@form[:"networks[#{i}][network_id]"]}
                  type="select"
                  label="Red Social"
                  options={@network_options}
                  prompt="Seleccionar red social"
                  name={"networks[#{i}][network_id]"}
                />
              </div>
              <div>
                <.input
                  field={@form[:"networks[#{i}][username]"]}
                  type="text"
                  label="Usuario"
                  name={"networks[#{i}][username]"}
                />
              </div>
            </div>

            <div class="mt-2">
              <.input
                field={@form[:"networks[#{i}][url]"]}
                type="text"
                label="URL"
                placeholder="Se generará automáticamente si no se especifica"
                name={"networks[#{i}][url]"}
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
          username: pn.username,
          url: pn.url
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

    # Crear un form con redes preconfiguradas
    form = to_form(changeset)
    form = Enum.reduce(networks, form, fn network, acc ->
      i = Enum.find_index(networks, &(&1.id == network.id)) || 0
      acc
      |> add_field_to_form(:"networks[#{i}][network_id]", network.network_id)
      |> add_field_to_form(:"networks[#{i}][username]", network.username)
      |> add_field_to_form(:"networks[#{i}][url]", network.url)
    end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:networks, networks)
     |> assign(:network_options, network_options)
     |> assign(:form, form)}
  end

  # Función auxiliar para añadir un campo al form
  defp add_field_to_form(form, field_name, value) do
    %{form | source: Map.put(form.source, field_name, value)}
  end

  @impl true
  def handle_event("add-network", _, socket) do
    networks = socket.assigns.networks ++ [%{id: nil, network_id: nil, username: "", url: ""}]

    # Actualizar el formulario con el nuevo campo
    i = length(socket.assigns.networks)
    form = socket.assigns.form
    |> add_field_to_form(:"networks[#{i}][network_id]", nil)
    |> add_field_to_form(:"networks[#{i}][username]", "")
    |> add_field_to_form(:"networks[#{i}][url]", "")

    {:noreply,
     socket
     |> assign(:networks, networks)
     |> assign(:form, form)}
  end

  @impl true
  def handle_event("remove-network", %{"index" => index}, socket) do
    index = String.to_integer(index)
    networks = List.delete_at(socket.assigns.networks, index)

    # Reconstruir el formulario con los networks actualizados
    person_info = socket.assigns.person_info
    changeset = PersonInfo.changeset(person_info, %{
      full_name: person_info.full_name,
      short_name: person_info.short_name,
      phone: person_info.phone,
      identity_number: person_info.identity_number,
      birth_date: person_info.birth_date,
      gender: person_info.gender,
      extra_data: person_info.extra_data
    })

    form = to_form(changeset)
    form = Enum.reduce(Enum.with_index(networks), form, fn {network, i}, acc ->
      acc
      |> add_field_to_form(:"networks[#{i}][network_id]", network.network_id)
      |> add_field_to_form(:"networks[#{i}][username]", network.username)
      |> add_field_to_form(:"networks[#{i}][url]", network.url)
    end)

    {:noreply,
     socket
     |> assign(:networks, networks)
     |> assign(:form, form)}
  end
end
