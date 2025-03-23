defmodule TalentWeb.ScoringCriterionLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Scoring
  alias Talent.Competitions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Gestiona los criterios de puntuación para las competencias</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="criterion-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nombre" />
        <.input field={@form[:description]} type="textarea" label="Descripción" />
        <.input field={@form[:category_ids]} type="select" multiple label="Categorías" options={@categories} />
        <.input field={@form[:parent_id]} type="select" label="Criterio Padre (opcional)" options={@parent_criteria} prompt="Ninguno (criterio principal)" />
        <.input field={@form[:max_points]} type="number" label="Puntaje Máximo" />
        <.input field={@form[:is_discount]} type="checkbox" label="¿Es un descuento? (resta puntos en vez de sumarlos)" />

        <:actions>
          <.button phx-disable-with="Guardando...">Guardar Criterio</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{criterion: criterion} = assigns, socket) do
    # Obtener las categorías para el dropdown
    categories = Competitions.list_categories() |> Enum.map(fn c -> {c.name, c.id} end)

    # Precargar categorías si no están ya cargadas
    criterion = if Ecto.assoc_loaded?(criterion.categories), do: criterion, else: Talent.Repo.preload(criterion, :categories)

    # Obtener los IDs de las categorías asignadas
    category_ids = Enum.map(criterion.categories, & &1.id)

    # Obtener los criterios que pueden ser padres (sólo criterios principales)
    parent_criteria =
      Scoring.list_scoring_criteria()
      |> Enum.filter(fn c -> is_nil(c.parent_id) && (is_nil(criterion.id) || c.id != criterion.id) end)
      |> Enum.map(fn c -> {c.name, c.id} end)

    # Crear un changeset con los category_ids incluidos
    changeset =
      criterion
      |> Scoring.change_scoring_criterion()
      |> Ecto.Changeset.put_change(:category_ids, category_ids)

    {:ok,
    socket
    |> assign(assigns)
    |> assign(:categories, categories)
    |> assign(:parent_criteria, parent_criteria)
    |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"scoring_criterion" => criterion_params}, socket) do
    changeset =
      socket.assigns.criterion
      |> Scoring.change_scoring_criterion(criterion_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"scoring_criterion" => criterion_params}, socket) do
    # Extraer los IDs de las categorías seleccionadas
    category_ids =
      case Map.get(criterion_params, "category_ids", []) do
        ids when is_list(ids) ->
          Enum.map(ids, fn id ->
            case Integer.parse(id) do
              {num, _} -> num
              :error -> nil
            end
          end) |> Enum.reject(&is_nil/1)
        id when is_binary(id) ->
          case Integer.parse(id) do
            {num, _} -> [num]
            :error -> []
          end
        _ ->
          []
      end

    # Eliminar category_ids del mapa de params para que no interfiera con el changeset
    criterion_params = Map.delete(criterion_params, "category_ids")

    save_criterion(socket, socket.assigns.action, criterion_params, category_ids)
  end

  defp save_criterion(socket, :edit, criterion_params, category_ids) do
    case Scoring.update_scoring_criterion(socket.assigns.criterion, criterion_params) do
      {:ok, criterion} ->
        # Asignar las categorías seleccionadas
        Scoring.assign_categories_to_criterion(criterion.id, category_ids)

        # Volver a cargar el criterio con todas las relaciones actualizadas
        updated_criterion = Scoring.get_scoring_criterion!(criterion.id)

        # Notificar al padre con el criterio completamente actualizado
        notify_parent({:saved, updated_criterion})

        {:noreply,
         socket
         |> put_flash(:info, "Criterio actualizado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_criterion(socket, :new, criterion_params, category_ids) do
    case Scoring.create_scoring_criterion(criterion_params) do
      {:ok, criterion} ->
        # Asignar las categorías seleccionadas
        Scoring.assign_categories_to_criterion(criterion.id, category_ids)

        # Volver a cargar el criterio con todas las relaciones actualizadas
        updated_criterion = Scoring.get_scoring_criterion!(criterion.id)

        # Notificar al padre con el criterio completamente actualizado
        notify_parent({:saved, updated_criterion})

        {:noreply,
         socket
         |> put_flash(:info, "Criterio creado correctamente")
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
