defmodule TalentWeb.CategoryLive.Index do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Competitions.Category
  alias Talent.Repo

  @impl true
  def mount(_params, _session, socket) do
    # Get all categories with parent_category preloaded
    categories = Competitions.list_categories()

    # Create a lookup map for parent categories
    parent_categories = Enum.filter(categories, & &1.father)
    parent_map = Enum.into(parent_categories, %{}, fn c -> {c.id, c} end)

    # Add parent_name to all categories with a father_id
    categories_with_parent_names =
      Enum.map(categories, fn category ->
        if category.father_id do
          parent_name = case category.parent_category do
            %Ecto.Association.NotLoaded{} ->
              # Fallback if preload somehow failed
              get_in(parent_map, [category.father_id, :name]) || "Desconocida"
            nil ->
              "Desconocida"
            parent ->
              parent.name
          end
          Map.put(category, :parent_name, parent_name)
        else
          category
        end
      end)

    {:ok, stream(socket, :categories, categories_with_parent_names)}
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
    # Preload the parent relationship and add parent name if needed
    category_with_parent =
      category
      |> Repo.preload(:parent_category)
      |> maybe_add_parent_name()

    {:noreply, stream_insert(socket, :categories, category_with_parent)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Competitions.get_category!(id)

    # Check if this is a parent category with children
    has_children =
      Competitions.list_categories_by_parent(category.id)
      |> Enum.any?()

    if has_children do
      {:noreply,
        socket
        |> put_flash(:error, "No se puede eliminar una categoría padre que tiene categorías hijas asociadas.")}
    else
      case Competitions.delete_category(category) do
        {:ok, _} ->
          {:noreply, stream_delete(socket, :categories, category)}

        {:error, changeset} ->
          {:noreply,
            socket
            |> put_flash(:error, "Error al eliminar la categoría: #{inspect(changeset.errors)}")}
      end
    end
  end

  # Helper function to add parent_name to a category
  defp maybe_add_parent_name(category) do
    if category.father_id && category.parent_category do
      Map.put(category, :parent_name, category.parent_category.name)
    else
      category
    end
  end
end
