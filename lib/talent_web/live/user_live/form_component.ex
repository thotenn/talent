defmodule TalentWeb.UserLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Accounts
  alias Talent.Accounts.{PersonInfo}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Complete los datos del usuario</:subtitle>
      </.header>

      <form id="user-form" phx-target={@myself} phx-submit="save">
        <.input field={@form[:email]} type="email" label="Email" />
        <.input field={@form[:role]} type="select" label="Rol" options={[
          {"Administrador", "administrador"},
          {"Jurado", "jurado"},
          {"Secretario", "secretario"},
          {"Escribana", "escribana"}
        ]} />
        <.input field={@form[:password]} type="password" label="Contraseña" />

        <div class="border-t border-gray-300 my-6 pt-6">
          <.live_component
            module={TalentWeb.PersonInfoLive.FormComponent}
            id="person-info-form"
            person_info={@person_info}
            title="Información Personal"
          />
        </div>

        <div class="mt-6">
          <.button type="submit" phx-disable-with="Guardando...">Guardar Usuario</.button>
        </div>
      </form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    # Cargar o crear la información personal relacionada con este usuario
    person_info = if user.person_id do
      Accounts.get_person_info!(user.person_id)
    else
      %PersonInfo{}
    end

    changeset = if user.id do
      Accounts.change_user(user)
    else
      Accounts.change_user_registration(user)
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:person_info, person_info)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", params, socket) do
    user_params = Map.get(params, "user", %{})
    person_info_params = Map.get(params, "person_info", %{})
    networks_params = Map.get(params, "networks", %{})

    save_user(socket, socket.assigns.action, user_params, person_info_params, networks_params)
  end

  defp save_user(socket, :edit, user_params, person_info_params, networks_params) do
    user = socket.assigns.user

    # Eliminar campos vacíos de person_info_params
    person_info_params = clean_empty_params(person_info_params)

    result = Accounts.update_user_with_person_info(user, user_params, person_info_params, networks_params)

    case result do
      {:ok, %{user: updated_user}} ->
        # Si hay contraseña, actualizarla separadamente
        updated_user =
          if user_params["password"] && String.trim(user_params["password"]) != "" do
            password_params = %{
              "password" => user_params["password"],
              "password_confirmation" => user_params["password"]
            }

            case Accounts.reset_user_password(user, password_params) do
              {:ok, pw_updated_user} -> pw_updated_user
              {:error, _changeset} -> updated_user
            end
          else
            updated_user
          end

        notify_parent({:saved, updated_user})

        {:noreply,
         socket
         |> put_flash(:info, "Usuario actualizado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, failed_operation, failed_value, _changes} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error al guardar: #{inspect(failed_operation)}")
         |> assign_form(failed_value)}
    end
  end

  defp save_user(socket, :new, user_params, person_info_params, networks_params) do
    # Eliminar campos vacíos de person_info_params
    person_info_params = clean_empty_params(person_info_params)

    result = Accounts.create_user_with_person_info(user_params, person_info_params, networks_params)

    case result do
      {:ok, %{user: user}} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Usuario creado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, failed_operation, failed_value, _changes} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error al guardar: #{inspect(failed_operation)}")
         |> assign_form(failed_value)}
    end
  end

  # Función para limpiar campos vacíos de los parámetros de person_info
  defp clean_empty_params(params) do
    if is_map(params) do
      params
      |> Enum.filter(fn {_k, v} -> v && v != "" end)
      |> Map.new()
    else
      %{}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
