defmodule TalentWeb.UserLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Accounts
  alias Talent.Directory
  alias TalentWeb.Components.PersonForm

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Complete los datos del usuario</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:email]} type="email" label="Email" />
        <.input field={@form[:role]} type="select" label="Rol" options={[
          {"Administrador", "administrador"},
          {"Jurado", "jurado"},
          {"Secretario", "secretario"},
          {"Escribana", "escribana"}
        ]} />
        <.input field={@form[:password]} type="password" label="Contraseña" phx-debounce="blur" />

        <!-- Información personal -->
        <PersonForm.person_form_fields person={@user.person} field_name="person_data" />

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

        <:actions>
          <.button phx-disable-with="Guardando...">Guardar Usuario</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    # Asegurarnos de que precarguemos la persona y sus redes sociales si existe
    user = cond do
      is_nil(user) ->
        %Talent.Accounts.User{}
      is_nil(user.id) ->
        user
      true ->
        # Precargamos explícitamente la persona y sus redes
        Accounts.get_user_with_person!(user.id)
    end

    changeset = if user.id do
      Accounts.change_user(user)
    else
      Accounts.change_user_registration(user)
    end

    # Inicializar person_data para el formulario si no existe
    changeset = if !Map.has_key?(changeset.params || %{}, "person_data") do
      if Ecto.assoc_loaded?(user.person) && user.person do
        # Si hay una persona asociada, inicializar con sus datos
        person_data = %{
          "full_name" => user.person.full_name,
          "short_name" => user.person.short_name,
          "phone" => user.person.phone,
          "identity_number" => user.person.identity_number,
          "birth_date" => user.person.birth_date,
          "gender" => user.person.gender,
          "extra_data" => user.person.extra_data
        }

        # Si hay redes sociales, añadirlas
        networks_data = if Ecto.assoc_loaded?(user.person.person_networks) do
          Enum.map(user.person.person_networks, fn pn ->
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
    else
      changeset
    end

    # Obtener la lista de redes para el select
    networks = Directory.list_networks() |> Enum.map(fn n -> {n.name, n.id} end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user, user)
     |> assign(:networks, networks)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = if socket.assigns.user.id do
      Accounts.change_user(socket.assigns.user, user_params)
    else
      Accounts.change_user_registration(socket.assigns.user, user_params)
    end

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", params, socket) do
    IO.puts("Evento save recibido en UserFormComponent: #{inspect(params)}")

    # Extraer parámetros relevantes
    user_params = params["user"] || %{}
    person_data = params["person_data"] || %{}

    # Extraer datos de redes sociales si existen
    networks_data = person_data["networks_data"] || []

    # Si hay datos de persona y son válidos, agregarlos a user_params
    if Map.has_key?(person_data, "full_name") && String.trim(person_data["full_name"] || "") != "" do
      # Asegurarse de que person_data contiene networks_data
      person_data = Map.put(person_data, "networks_data", networks_data)
      user_params = Map.put(user_params, "person_data", person_data)
    end

    IO.puts("User params procesados: #{inspect(user_params)}")

    # Llamar a save_user con los parámetros procesados
    save_user(socket, socket.assigns.action, user_params)
  end

  def handle_event("add-network", _params, socket) do
    network_id = socket.assigns.form.params["new_network_id"]
    username = socket.assigns.form.params["new_username"]

    IO.puts("Añadiendo red social: network_id=#{inspect(network_id)}, username=#{inspect(username)}")

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
      changeset = if socket.assigns.user.id do
        Accounts.change_user(socket.assigns.user, updated_params)
      else
        Accounts.change_user_registration(socket.assigns.user, updated_params)
      end

      # Actualizar el formulario
      updated_form = to_form(changeset, action: :validate)

      # Limpiar los campos de entrada
      socket =
        socket
        |> push_event("clear-network-inputs", %{})

      {:noreply, assign(socket, form: updated_form)}
    else
      # Si faltan datos, no hacer nada
      {:noreply, socket}
    end
  end

  def handle_event("remove-network", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)

    IO.puts("Eliminando red social en índice #{index}")

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
    changeset = if socket.assigns.user.id do
      Accounts.change_user(socket.assigns.user, updated_params)
    else
      Accounts.change_user_registration(socket.assigns.user, updated_params)
    end

    # Actualizar el formulario
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user_with_person(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Usuario actualizado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.register_user_with_person(user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Usuario creado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
