defmodule TalentWeb.UserLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Accounts
  import TalentWeb.Components.PersonForm

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
        <.person_form_fields person={@user.person} field_name="person_data" />

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

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user, user)
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

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
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
