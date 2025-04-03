defmodule TalentWeb.JudgeLive.Index do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Repo

  @impl true
  def mount(_params, _session, socket) do
    # Cargar jueces con sus categorías relacionadas
    judges = Competitions.list_judges()
      |> Repo.preload([:user])

    # Precargar las categorías, pero asegurarnos de que no incluyan categorías padre
    judges_with_filtered_categories = Enum.map(judges, fn judge ->
      categories = Competitions.list_categories_by_judge(judge.id)
      %{judge | categories: categories}
    end)

    # Inicializar el stream con los jueces precargados
    {:ok, stream(socket, :judges, judges_with_filtered_categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Juez")
    |> assign(:judge, Competitions.get_judge!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nuevo Juez")
    |> assign(:judge, %Talent.Competitions.Judge{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listado de Jueces")
    |> assign(:judge, nil)
  end

  @impl true
def handle_event("delete", %{"id" => id}, socket) do
  judge = Competitions.get_judge!(id)
  {:ok, _} = Competitions.delete_judge(judge)

  {:noreply, stream_delete(socket, :judges, judge)}
end
end
