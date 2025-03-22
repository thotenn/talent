defmodule TalentWeb.UserLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Accounts
  alias Talent.Competitions

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
        <:actions>
          <.button phx-disable-with="Guardando...">Guardar Usuario</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = if user.id do
      Accounts.change_user(user)
    else
      Accounts.change_user_registration(user)
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(socket.assigns.user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        # Si el rol es "jurado", asegurarse de que tenga un perfil de juez
        if user.role == "jurado" do
          ensure_judge_profile(user)
        end

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
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        # Si el rol es "jurado", crear un perfil de juez
        if user.role == "jurado" do
          ensure_judge_profile(user)
        end

        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Usuario creado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp ensure_judge_profile(user) do
    # Verificar si ya existe un juez asociado
    case Competitions.get_judge_by_user_id(user.id) do
      nil ->
        # No existe, crear uno nuevo usando el email como nombre por defecto
        Competitions.create_judge(%{
          name: user.email,
          user_id: user.id
        })

      _judge ->
        # Ya existe un juez, no hacer nada
        {:ok, nil}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
