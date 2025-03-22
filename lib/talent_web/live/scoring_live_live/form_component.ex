defmodule TalentWeb.ScoringLiveLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Scoring

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Usa este formulario para gestionar los scoring_live en tu base de datos.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="scoring_live-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:judge_id]} type="number" label="Judge" />
        <:actions>
          <.button phx-disable-with="Guardando...">Guardar Scoring live</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{scoring_live: scoring_live} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Scoring.change_scoring_live(scoring_live))
     end)}
  end

  @impl true
  def handle_event("validate", %{"scoring_live" => scoring_live_params}, socket) do
    changeset = Scoring.change_scoring_live(socket.assigns.scoring_live, scoring_live_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"scoring_live" => scoring_live_params}, socket) do
    save_scoring_live(socket, socket.assigns.action, scoring_live_params)
  end

  defp save_scoring_live(socket, :edit, scoring_live_params) do
    case Scoring.update_scoring_live(socket.assigns.scoring_live, scoring_live_params) do
      {:ok, scoring_live} ->
        notify_parent({:saved, scoring_live})

        {:noreply,
         socket
         |> put_flash(:info, "Scoring live actualizado exitosamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_scoring_live(socket, :new, scoring_live_params) do
    case Scoring.create_scoring_live(scoring_live_params) do
      {:ok, scoring_live} ->
        notify_parent({:saved, scoring_live})

        {:noreply,
         socket
         |> put_flash(:info, "Scoring live creado exitosamente")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
