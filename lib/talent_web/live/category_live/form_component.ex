defmodule TalentWeb.CategoryLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Competitions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Usa este formulario para gestionar las categorías en tu base de datos.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nombre" />
        <.input field={@form[:description]} type="text" label="Descripción" />

        <div class="mt-4">
          <.input field={@form[:father]} type="checkbox" label="Es Categoría Padre" phx-change="toggle_father" phx-target={@myself} />
        </div>

        <div class="mt-4">
          <%= if !@is_father do %>
            <.input field={@form[:max_points]} type="number" label="Máxima puntuación" />

            <div class="mt-4">
              <.input field={@form[:father_id]} type="select" label="Categoría Padre (opcional)" options={@parent_options} prompt="Sin categoría padre" />
            </div>
          <% else %>
            <div class="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 mb-4" role="alert">
              <p>Las categorías padre no pueden tener puntuación máxima ni categoría padre.</p>
            </div>
          <% end %>
        </div>

        <:actions>
          <.button phx-disable-with="Guardando...">Guardar Categoría</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{category: category} = assigns, socket) do
    changeset = Competitions.change_category(category)
    is_father = Map.get(category, :father, false)

    # Get parent category options (only existing parent categories)
    parent_options =
      Competitions.list_parent_categories()
      |> Enum.filter(fn c -> c.id != category.id end) # Exclude self if editing
      |> Enum.map(fn c -> {c.name, c.id} end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:is_father, is_father)
     |> assign(:parent_options, parent_options)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("toggle_father", %{"category" => %{"father" => father}}, socket) do
    is_father = father == "true"

    {:noreply, socket |> assign(:is_father, is_father)}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      socket.assigns.category
      |> Competitions.change_category(category_params)
      |> Map.put(:action, :validate)

    # Update is_father state based on the current value
    is_father =
      case Map.get(category_params, "father") do
        "true" -> true
        "false" -> false
        _ -> socket.assigns.is_father
      end

    {:noreply,
     socket
     |> assign(:is_father, is_father)
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    # Apply special rules for father categories
    category_params = case Map.get(category_params, "father") do
      "true" ->
        category_params
        |> Map.put("max_points", nil)
        |> Map.put("father_id", nil)
      _ ->
        category_params
    end

    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :edit, category_params) do
    case Competitions.update_category(socket.assigns.category, category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> put_flash(:info, "Categoría actualizada exitosamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_category(socket, :new, category_params) do
    case Competitions.create_category(category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> put_flash(:info, "Categoría creada exitosamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
