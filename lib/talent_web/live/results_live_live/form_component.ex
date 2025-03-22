defmodule TalentWeb.ResultsLiveLive.FormComponent do
  use TalentWeb, :live_component

  alias Talent.Results

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage results_live records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="results_live-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:category_id]} type="number" label="Category" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Results live</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{results_live: results_live} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Results.change_results_live(results_live))
     end)}
  end

  @impl true
  def handle_event("validate", %{"results_live" => results_live_params}, socket) do
    changeset = Results.change_results_live(socket.assigns.results_live, results_live_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"results_live" => results_live_params}, socket) do
    save_results_live(socket, socket.assigns.action, results_live_params)
  end

  defp save_results_live(socket, :edit, results_live_params) do
    case Results.update_results_live(socket.assigns.results_live, results_live_params) do
      {:ok, results_live} ->
        notify_parent({:saved, results_live})

        {:noreply,
         socket
         |> put_flash(:info, "Results live updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_results_live(socket, :new, results_live_params) do
    case Results.create_results_live(results_live_params) do
      {:ok, results_live} ->
        notify_parent({:saved, results_live})

        {:noreply,
         socket
         |> put_flash(:info, "Results live created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
