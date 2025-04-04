defmodule TalentWeb.DashboardLive do
  use TalentWeb, :live_view

  alias Talent.Competitions

  on_mount {TalentWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    # Verificar si el usuario es un juez y tiene acceso a resultados
    has_scores_access = if current_user.role == "jurado" do
      case Competitions.get_judge_by_user_id(current_user.id) do
        nil -> false
        judge -> judge.scores_access
      end
    else
      # Para otros roles (admin, escribana, secretario) siempre true
      true
    end

    {:ok,
     assign(socket,
       page_title: "Dashboard",
       user_role: current_user.role,
       has_scores_access: has_scores_access
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Talent</h1>

      <div class="bg-white shadow-md rounded-lg p-6 mb-8">
        <h2 class="text-xl font-semibold mb-4">
          Bienvenido/a, &nbsp;
          <span class="font-medium text-zinc-600">{@current_user.email}</span>
        </h2>
        <p class="mb-2">
          <span class="font-medium">{String.capitalize(@user_role)}</span>
        </p>

        <div class="mt-6 dark:text-black">
          <%= case @user_role do %>
            <% "administrador" -> %>
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
                <.link
                  navigate={~p"/admin/users"}
                  class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">👥</div>
                  <div class="font-medium">Gestionar Usuarios</div>
                </.link>
                <.link
                  navigate={~p"/admin/categories"}
                  class="bg-green-100 hover:bg-green-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">🏆</div>
                  <div class="font-medium">Gestionar Categorías</div>
                </.link>
                <.link
                  navigate={~p"/admin/scoring_criteria"}
                  class="bg-purple-100 hover:bg-purple-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">📋</div>
                  <div class="font-medium">Criterios de Calificación</div>
                </.link>
                <.link
                  navigate={~p"/admin/judges"}
                  class="bg-amber-100 hover:bg-amber-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">⚖️</div>
                  <div class="font-medium">Gestionar Jueces</div>
                </.link>
                <.link
                  navigate={~p"/secretary/participants"}
                  class="bg-red-100 hover:bg-red-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">🕺</div>
                  <div class="font-medium">Gestionar Participantes</div>
                </.link>
                <.link
                  navigate={~p"/notary/results"}
                  class="bg-indigo-100 hover:bg-indigo-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">📊</div>
                  <div class="font-medium">Ver Resultados</div>
                </.link>

                <.link
                  navigate={~p"/admin/networks"}
                  class="bg-blue-100 hover:bg-blue-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">🔗</div>
                  <div class="font-medium">Redes Sociales</div>
                </.link>
              </div>
            <% "jurado" -> %>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
                <.link
                  navigate={~p"/jury/scoring"}
                  class="bg-yellow-100 hover:bg-yellow-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">⭐</div>
                  <div class="font-medium">Calificar Participantes</div>
                </.link>
                <%= if @has_scores_access do %>
                  <.link
                    navigate={~p"/notary/results"}
                    class="bg-indigo-100 hover:bg-indigo-200 p-4 rounded-lg text-center"
                  >
                    <div class="text-xl mb-2">📊</div>
                    <div class="font-medium">Ver Resultados</div>
                  </.link>
                <% end %>
              </div>
            <% "secretario" -> %>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
                <.link
                  navigate={~p"/secretary/participants"}
                  class="bg-red-100 hover:bg-red-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">🕺</div>
                  <div class="font-medium">Gestionar Participantes</div>
                </.link>
                <.link
                  navigate={~p"/notary/results"}
                  class="bg-indigo-100 hover:bg-indigo-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">📊</div>
                  <div class="font-medium">Ver Resultados</div>
                </.link>
              </div>
            <% "escribana" -> %>
              <div class="grid grid-cols-1 gap-4 mt-6">
                <.link
                  navigate={~p"/notary/results"}
                  class="bg-indigo-100 hover:bg-indigo-200 p-4 rounded-lg text-center"
                >
                  <div class="text-xl mb-2">📊</div>
                  <div class="font-medium">Ver Resultados Detallados</div>
                </.link>
              </div>
            <% _ -> %>
              <p class="mt-4 text-gray-600">No hay opciones disponibles para este rol.</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
