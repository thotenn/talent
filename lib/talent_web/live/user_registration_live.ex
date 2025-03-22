defmodule TalentWeb.UserRegistrationLive do
  use TalentWeb, :live_view

  alias Talent.Accounts
  alias Talent.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Regístrate
        <:subtitle>
          Ya tienes una cuenta?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Iniciar sesión
          </.link>
          para iniciar sesión.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Ups, algo salió mal! Por favor, verifica los errores abajo.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Contraseña" required />

        <:actions>
          <.button phx-disable-with="Creando cuenta..." class="w-full bg-zinc-900 hover:bg-zinc-700">Crear cuenta</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        # Ahora en lugar de usar trigger_submit: true, vamos a redirigir manualmente
        {:noreply,
          socket
          |> put_flash(:info, "Tu registro se ha enviado correctamente. Un administrador revisará tu solicitud para su aprobación.")
          |> redirect(to: ~p"/users/log_in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
