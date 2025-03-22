defmodule TalentWeb.ScoringCriterionLive.Show do
  use TalentWeb, :live_view

  alias Talent.Scoring

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    criterion = Scoring.get_scoring_criterion!(id)

    {:noreply,
     socket
     |> assign(:page_title, "Detalles del Criterio")
     |> assign(:criterion, criterion)}
  end
end
