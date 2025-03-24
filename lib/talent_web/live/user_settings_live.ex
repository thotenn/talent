defmodule TalentWeb.UserSettingsLive do
  use TalentWeb, :live_view

  alias Talent.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Configuración
      <:subtitle>Administra tu dirección de correo electrónico y contraseña</:subtitle>
    </.header>

    <div class="block md:hidden">
      <.install_button />
    </div>

    <div class="mb-8 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg shadow">
      <h3 class="text-lg font-medium mb-2 dark:text-white">Preferencias de visualización</h3>
      <div class="flex items-center space-x-2">
        <input
          type="checkbox"
          id="dark-mode-checkbox"
          class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
          onclick="toggleDarkMode()"
        />
        <label for="dark-mode-checkbox" class="font-medium text-sm dark:text-white">
          Activar modo oscuro
        </label>
      </div>
      <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">El modo oscuro reduce el cansancio visual en entornos con poca luz.</p>

      <script>
        // Aplicar modo oscuro inmediatamente basado en localStorage
        if (localStorage.getItem('darkMode') === 'dark') {
          document.documentElement.classList.add('dark');
        } else {
          document.documentElement.classList.remove('dark');
        }

        // Función para actualizar el estado del checkbox
        function updateCheckboxState() {
          const checkbox = document.getElementById('dark-mode-checkbox');
          if (checkbox) {
            checkbox.checked = localStorage.getItem('darkMode') === 'dark';
          }
        }

        // Ejecutar cuando el DOM esté listo
        document.addEventListener('DOMContentLoaded', updateCheckboxState);

        // Ejecutar inmediatamente también (para cuando la página se carga por navegación)
        updateCheckboxState();

        // IMPORTANTE: Agregar un callback para cuando LiveView actualiza el DOM
        document.addEventListener('phx:update', updateCheckboxState);

        // Función global para cambiar el modo oscuro (llamada desde onclick)
        function toggleDarkMode() {
          const checkbox = document.getElementById('dark-mode-checkbox');
          if (!checkbox) return;

          if (checkbox.checked) {
            document.documentElement.classList.add('dark');
            localStorage.setItem('darkMode', 'dark');
          } else {
            document.documentElement.classList.remove('dark');
            localStorage.setItem('darkMode', 'light');
          }
        }
      </script>
    </div>

    <div class="space-y-12 divide-y divide-gray-200 dark:divide-gray-700">
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Contraseña actual"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Cambiando...">Cambiar Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="Contraseña nueva" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirmar contraseña nueva"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Contraseña actual"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Cambiando...">Cambiar Contraseña</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email cambiado exitosamente.")

        :error ->
          put_flash(socket, :error, "El enlace de cambio de email es inválido o ha expirado.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "Se ha enviado un enlace de confirmación a la nueva dirección."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  # Ya no necesitamos el manejador para actualizar el estado desde el cliente
  # porque todo se gestiona ahora en JavaScript

  # Manejador para cambiar el modo oscuro
  def handle_event("toggle_dark_mode", _params, socket) do
    # Invertir el estado actual
    new_dark_mode = !socket.assigns.dark_mode_enabled

    # No intentamos modificar la sesión directamente aquí,
    # en su lugar usamos localStorage en el cliente

    # Emitir evento JS para aplicar o quitar el modo oscuro
    socket = push_event(socket, "toggle-dark-mode", %{enabled: new_dark_mode})

    {:noreply, assign(socket, :dark_mode_enabled, new_dark_mode)}
  end
end
