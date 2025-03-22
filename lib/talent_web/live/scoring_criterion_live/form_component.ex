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
        <.input field={@form[:category_id]} type="select" label="Categoría" options={@categories} />
        <.input field={@form[:parent_id]} type="select" label="Criterio Padre (opcional)" options={@parent_criteria} prompt="Ninguno (criterio principal)" />
        <.input field={@form[:max_points]} type="number" label="Puntaje Máximo" />

        <:actions>
          <.button phx-disable-with="Guardando...">Guardar Criterio</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{criterion: criterion} = assigns, socket) do
    # Obtener la lista de categorías para el dropdown
    categories = Competitions.list_categories() |> Enum.map(fn c -> {c.name, c.id} end)

    # Obtener la lista de criterios que pueden ser padres (solo criterios principales)
    parent_criteria =
      Scoring.list_scoring_criteria()
      |> Enum.filter(fn c -> is_nil(c.parent_id) end)
      |> Enum.map(fn c -> {c.name, c.id} end)

    changeset = Scoring.change_scoring_criterion(criterion)

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
    save_criterion(socket, socket.assigns.action, criterion_params)
  end

  defp save_criterion(socket, :edit, criterion_params) do
    case Scoring.update_scoring_criterion(socket.assigns.criterion, criterion_params) do
      {:ok, criterion} ->
        notify_parent({:saved, criterion})

        {:noreply,
         socket
         |> put_flash(:info, "Criterio actualizado correctamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_criterion(socket, :new, criterion_params) do
    case Scoring.create_scoring_criterion(criterion_params) do
      {:ok, criterion} ->
        notify_parent({:saved, criterion})

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
