defmodule TalentWeb.Components.PersonDetail do
  use TalentWeb, :html

  alias Talent.Directory

  attr :person, :map, required: true

  def person_detail(assigns) do
    # Verificar si la persona está correctamente cargada y asignar a una nueva clave
    assigns =
      if is_struct(assigns.person, Ecto.Association.NotLoaded) do
        assign(assigns, :person_loaded, false)
      else
        # La persona está cargada, buscar sus redes sociales
        networks =
          if assigns.person && assigns.person.id do
            Directory.get_networks_for_person(assigns.person.id)
          else
            []
          end
        assigns
        |> assign(:person_loaded, true)
        |> assign(:networks, networks)
      end

    ~H"""
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
      <div class="px-4 py-5 sm:px-6">
        <h3 class="text-lg leading-6 font-medium text-gray-900">Información Personal</h3>
        <p class="mt-1 max-w-2xl text-sm text-gray-500">Detalles del perfil personal.</p>
      </div>

      <%= if !@person_loaded do %>
        <div class="border-t border-gray-200 p-4">
          <p class="text-sm text-gray-500 italic">La información personal no está disponible o no ha sido cargada.</p>
        </div>
      <% else %>
        <div class="border-t border-gray-200">
          <dl>
            <!-- Mostrar cada campo si no está vacío -->
            <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Nombre completo</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2"><%= @person.full_name %></dd>
            </div>

          <%= if @person.short_name do %>
            <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Nombre corto o alias</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2"><%= @person.short_name %></dd>
            </div>
          <% end %>

          <%= if @person.phone do %>
            <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Teléfono</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2"><%= @person.phone %></dd>
            </div>
          <% end %>

          <%= if @person.identity_number do %>
            <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Número de identidad</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2"><%= @person.identity_number %></dd>
            </div>
          <% end %>

          <%= if @person.birth_date do %>
            <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Fecha de nacimiento</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                <%= Calendar.strftime(@person.birth_date, "%d/%m/%Y") %>
              </dd>
            </div>
          <% end %>

          <%= if @person.gender do %>
            <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Género</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2"><%= @person.gender %></dd>
            </div>
          <% end %>

          <%= if @person.extra_data do %>
            <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Datos adicionales</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2 whitespace-pre-line"><%= @person.extra_data %></dd>
            </div>
          <% end %>

          <!-- Redes sociales -->
          <%= if @networks && Enum.any?(@networks) do %>
            <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Redes sociales</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                <ul class="border border-gray-200 rounded-md divide-y divide-gray-200">
                  <%= for network <- @networks do %>
                    <li class="pl-3 pr-4 py-3 flex items-center justify-between text-sm">
                      <div class="w-0 flex-1 flex items-center">
                        <span class="flex-1 w-0 truncate">
                          <span class="font-medium"><%= network.name %>:</span> <%= network.username %>
                        </span>
                      </div>
                      <%= if network.url do %>
                        <div class="ml-4 flex-shrink-0">
                          <a href={network.url} target="_blank" class="font-medium text-indigo-600 hover:text-indigo-500">
                            Abrir
                          </a>
                        </div>
                      <% end %>
                    </li>
                  <% end %>
                </ul>
              </dd>
            </div>
          <% end %>
        </dl>
      </div>
      <% end %>
    </div>
    """
  end
end
