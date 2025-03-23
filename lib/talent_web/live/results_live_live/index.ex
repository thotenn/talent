defmodule TalentWeb.ResultsLive.Index do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Repo

  on_mount {TalentWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    categories = case current_user.role do
      "jurado" ->
        # Obtener el juez asociado al usuario actual
        judge = Competitions.get_judge_by_user_id(current_user.id)

        if judge do
          # Verificar si el juez tiene acceso a los resultados
          if judge.scores_access do
            # Obtener las categorías asignadas a este juez
            judge = Repo.preload(judge, :categories)
            judge.categories
          else
            # Redirigir y mostrar mensaje de error, pero continuar con lista vacía
            send(self(), {:flash_and_redirect, socket, :error,
              "No tienes acceso a ver los resultados en tiempo real. Contacta al administrador."})
            []
          end
        else
          # Si no hay juez asignado, devolver lista vacía
          []
        end
      _ ->
        # Para otros roles (escribana, administrador), mostrar todas las categorías
        Competitions.list_categories()
    end

    {:ok, socket
      |> assign(:categories, categories)
      |> assign(:page_title, "Resultados de la Competencia")
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Resultados de la Competencia")
  end

  # Manejador para el mensaje flash_and_redirect
  @impl true
  def handle_info({:flash_and_redirect, socket, level, message}, _socket) do
    {:noreply,
      socket
      |> put_flash(level, message)
      |> redirect(to: ~p"/")}
  end
end
