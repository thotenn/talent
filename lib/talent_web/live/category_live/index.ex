defmodule TalentWeb.CategoryLive.Index do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Competitions.Category

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :categories, Competitions.list_categories())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Categoría")
    |> assign(:category, Competitions.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nueva Categoría")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Categorías")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({TalentWeb.CategoryLive.FormComponent, {:saved, category}}, socket) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Competitions.get_category!(id)
    {:ok, _} = Competitions.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end
end
