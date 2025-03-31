defmodule TalentWeb.UserLive.Index do
  use TalentWeb, :live_view

  alias Talent.Accounts
  alias Talent.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users() |> Talent.Repo.preload(:person)
    {:ok, stream(socket, :users, users)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = Accounts.get_user!(id) |> Talent.Repo.preload(:person)
    socket
    |> assign(:page_title, "Editar Usuario")
    |> assign(:user, user)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nuevo Usuario")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Gestión de Usuarios")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({TalentWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    user = Talent.Repo.preload(user, :person)
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("confirm_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    {:ok, updated_user} =
      user
      |> Ecto.Changeset.change(confirmed_at: now)
      |> Talent.Repo.update()

    updated_user = Talent.Repo.preload(updated_user, :person)
    {:noreply, stream_insert(socket, :users, updated_user)}
  end

  @impl true
  def handle_event("deactivate_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.deactivate_user(user) do
      {:ok, updated_user} ->
        updated_user = Talent.Repo.preload(updated_user, :person)
        {:noreply,
        socket
        |> put_flash(:info, "Usuario desactivado correctamente.")
        |> stream_insert(:users, updated_user)}

      {:error, _} ->
        {:noreply,
        socket
        |> put_flash(:error, "No se pudo desactivar el usuario.")}
    end
  end
end
