defmodule TalentWeb.Components.PersonForm do
  use TalentWeb, :html

  alias Talent.Directory.PersonInfo
  alias Talent.Directory

  attr :person, :map, default: %{}
  attr :field_name, :string, default: "person_data"

  def person_form_fields(assigns) do
    # Ajustamos assigns para asegurar que tenemos person incluso si es nil
    assigns = assign_new(assigns, :person, fn -> nil end)

    # Obtenemos los género disponibles
    gender_options = PersonInfo.gender_options() |> Enum.map(&{&1, &1})

    # Lista de todas las redes sociales disponibles
    networks = Directory.list_networks() |> Enum.map(&{&1.name, &1.id})

    # Verificar si la persona está realmente cargada y tiene ID
    person_networks =
      cond do
        is_nil(assigns.person) ->
          []
        is_struct(assigns.person, Ecto.Association.NotLoaded) ->
          # La asociación no está cargada
          []
        is_map(assigns.person) && Map.has_key?(assigns.person, :id) && not is_nil(assigns.person.id) ->
          # La persona está cargada y tiene ID
          Directory.get_networks_for_person(assigns.person.id)
        true ->
          []
      end

    # Añadimos estas variables a assigns
    assigns = assigns
      |> assign(:gender_options, gender_options)
      |> assign(:networks, networks)
      |> assign(:person_networks, person_networks)

    ~H"""
    <div class="mt-6 grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-6">
      <!-- Información básica de la persona -->
      <div class="sm:col-span-6">
        <h3 class="text-lg font-medium text-gray-900">Información Personal</h3>
        <p class="mt-1 text-sm text-gray-500">Ingrese los datos personales del perfil.</p>
      </div>

      <!-- Función auxiliar para extraer valores seguros de person -->
      <%
        get_person_field = fn field_name ->
          cond do
            is_nil(@person) -> nil
            is_struct(@person, Ecto.Association.NotLoaded) -> nil
            is_map(@person) -> Map.get(@person, field_name)
            true -> nil
          end
        end
      %>

      <!-- Nombre completo (Obligatorio) -->
      <div class="sm:col-span-6">
        <.input
          type="text"
          label="Nombre completo"
          name={"#{@field_name}[full_name]"}
          id={"#{@field_name}_full_name"}
          value={get_person_field.(:full_name)}
          required
        />
      </div>

      <!-- Nombre corto/Alias (Opcional) -->
      <div class="sm:col-span-3">
        <.input
          type="text"
          label="Nombre corto o alias"
          name={"#{@field_name}[short_name]"}
          id={"#{@field_name}_short_name"}
          value={get_person_field.(:short_name)}
        />
      </div>

      <!-- Teléfono (Opcional) -->
      <div class="sm:col-span-3">
        <.input
          type="tel"
          label="Teléfono"
          name={"#{@field_name}[phone]"}
          id={"#{@field_name}_phone"}
          value={get_person_field.(:phone)}
          placeholder="+123456789"
        />
      </div>

      <!-- Número de Identidad (Opcional) -->
      <div class="sm:col-span-3">
        <.input
          type="text"
          label="Número de Identidad"
          name={"#{@field_name}[identity_number]"}
          id={"#{@field_name}_identity_number"}
          value={get_person_field.(:identity_number)}
        />
      </div>

      <!-- Fecha de Nacimiento (Opcional) -->
      <div class="sm:col-span-3">
        <.input
          type="date"
          label="Fecha de Nacimiento"
          name={"#{@field_name}[birth_date]"}
          id={"#{@field_name}_birth_date"}
          value={get_person_field.(:birth_date)}
        />
      </div>

      <!-- Género (Opcional, pero con opciones limitadas) -->
      <div class="sm:col-span-3">
        <.input
          type="select"
          label="Género"
          name={"#{@field_name}[gender]"}
          id={"#{@field_name}_gender"}
          value={get_person_field.(:gender)}
          options={@gender_options}
          prompt="Seleccione un género"
        />
      </div>

      <!-- Datos adicionales (Opcional) -->
      <div class="sm:col-span-6">
        <.input
          type="textarea"
          label="Datos adicionales"
          name={"#{@field_name}[extra_data]"}
          id={"#{@field_name}_extra_data"}
          value={get_person_field.(:extra_data)}
          placeholder="Información adicional relevante..."
        />
      </div>

      <!-- Sección de Redes Sociales -->
      <div class="sm:col-span-6 mt-4">
        <h3 class="text-lg font-medium text-gray-900">Redes Sociales</h3>
        <p class="mt-1 text-sm text-gray-500">Añada sus perfiles en redes sociales.</p>
      </div>

      <!-- Redes sociales existentes -->
      <div class="sm:col-span-6" id="person-networks-container">
        <div class="mb-4">
          <table class="min-w-full divide-y divide-gray-300">
            <thead>
              <tr>
                <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900">Red Social</th>
                <th scope="col" class="py-3.5 px-3 text-left text-sm font-semibold text-gray-900">Nombre de Usuario</th>
                <th scope="col" class="py-3.5 px-3 text-left text-sm font-semibold text-gray-900">Enlace</th>
                <th scope="col" class="py-3.5 pl-3 pr-4 text-right text-sm font-semibold text-gray-900">Acciones</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <%= for {network, index} <- Enum.with_index(@person_networks) do %>
                <tr>
                  <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900">
                    <%= network.name %>
                    <input
                      type="hidden"
                      name={"#{@field_name}[networks_data][#{index}][network_id]"}
                      value={network.network_id}
                    />
                  </td>
                  <td class="whitespace-nowrap py-4 px-3 text-sm text-gray-500">
                    <input
                      type="text"
                      name={"#{@field_name}[networks_data][#{index}][username]"}
                      value={network.username}
                      class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                  </td>
                  <td class="whitespace-nowrap py-4 px-3 text-sm text-gray-500">
                    <%= if network.url do %>
                      <a href={network.url} target="_blank" class="text-indigo-600 hover:text-indigo-900">
                        <%= network.url %>
                      </a>
                    <% end %>
                  </td>
                  <td class="whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium">
                    <button
                      type="button"
                      phx-click="remove-network"
                      phx-value-index={index}
                      class="text-red-600 hover:text-red-900"
                    >
                      Eliminar
                    </button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Formulario para añadir una nueva red social -->
      <div class="sm:col-span-6 border-t pt-4">
        <div class="flex items-end gap-4">
          <div class="w-1/3">
            <.input
              type="select"
              label="Red Social"
              name="new_network_id"
              id="new_network_id"
              value=""
              options={@networks}
              prompt="Seleccione una red social"
            />
          </div>
          <div class="w-1/3">
            <.input
              type="text"
              label="Nombre de Usuario"
              name="new_username"
              id="new_username"
              value=""
              placeholder="@username"
            />
          </div>
          <div class="flex-shrink-0">
            <button
              type="button"
              phx-click="add-network"
              phx-target="#person-networks-container"
              class="inline-flex h-10 items-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
            >
              Añadir Red
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
