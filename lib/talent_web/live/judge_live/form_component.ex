defmodule TalentWeb.JudgeLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Competitions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Gestiona los jueces del sistema</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="judge-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nombre" />
        <.input field={@form[:user_id]} type="select" label="Usuario" options={@users_options} />

        <:actions>
          <.button phx-disable-with="Guardando...">Guardar Juez</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{judge: judge} = assigns, socket) do
    changeset = Competitions.change_judge(judge)

    # Obtener usuarios con rol de jurado que no tengan un juez asignado
    users_options = get_available_users(judge)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:users_options, users_options)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"judge" => judge_params}, socket) do
    changeset =
      socket.assigns.judge
      |> Competitions.change_judge(judge_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"judge" => judge_params}, socket) do
    save_judge(socket, socket.assigns.action, judge_params)
  end

  defp save_judge(socket, :edit, judge_params) do
    case Competitions.update_judge(socket.assigns.judge, judge_params) do
      {:ok, judge} ->
        notify_parent({:saved, judge})

        {:noreply,
         socket
         |> put_flash(:info, "Juez actualizado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_judge(socket, :new, judge_params) do
    case Competitions.create_judge(judge_params) do
      {:ok, judge} ->
        notify_parent({:saved, judge})

        {:noreply,
         socket
         |> put_flash(:info, "Juez creado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp get_available_users(judge) do
    # Si estamos editando, incluir el usuario actual del juez
    current_user_id = if judge.id, do: judge.user_id

    # Obtener usuarios con rol de jurado
    users_with_role = Talent.Accounts.list_users_by_role("jurado")

    # Obtener jueces existentes para filtrar usuarios
    existing_judges = Talent.Competitions.list_judges()
    existing_user_ids = Enum.map(existing_judges, & &1.user_id) -- [current_user_id]

    # Filtrar usuarios que ya tienen un juez asignado
    available_users = Enum.filter(users_with_role, fn user ->
      user.id not in existing_user_ids
    end)

    # Formatear para opciones de select
    Enum.map(available_users, fn user -> {user.email, user.id} end)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
