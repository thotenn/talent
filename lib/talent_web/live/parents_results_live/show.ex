defmodule TalentWeb.ParentResultsLive.Show do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Repo
  alias Decimal

  @impl true
  def mount(%{"parent_id" => parent_id}, _session, socket) do
    # Subscribe to score updates if connected
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Talent.PubSub, "scores:updates")
    end

    parent_id = String.to_integer(parent_id)
    parent_category = Competitions.get_category!(parent_id)

    # Get all child categories
    child_categories = Competitions.list_categories_by_parent(parent_id)

    # Get all judges from all child categories
    judges =
      Enum.flat_map(child_categories, fn category ->
        Competitions.list_judges_by_category(category.id)
      end)
      |> Enum.uniq_by(fn judge -> judge.id end)

    # Get all criteria from all child categories
    all_criteria =
      Enum.flat_map(child_categories, fn category ->
        Talent.Scoring.list_root_scoring_criteria_by_category(category.id)
      end)
      |> Enum.uniq_by(fn criterion -> criterion.id end)

    # Calculate combined results
    results = Competitions.calculate_parent_category_results(parent_id)

    {:ok, socket
      |> assign(:parent_id, parent_id)
      |> assign(:parent_category, parent_category)
      |> assign(:child_categories, child_categories)
      |> assign(:judges, judges)
      |> assign(:criteria, all_criteria)
      |> assign(:results, results)
      |> assign(:page_title, "Resultados Combinados: #{parent_category.name}")
    }
  end

  @impl true
  def handle_info({:score_updated, _details}, socket) do
    # Any score update should trigger a full recalculation for parent category
    results = Competitions.calculate_parent_category_results(socket.assigns.parent_id)

    {:noreply, socket |> assign(:results, results)}
  end

  # Helper function to format values (same as in ResultsLive.Show)
  defp format_value(value) when is_struct(value, Decimal) do
    Decimal.round(value, 0) |> Decimal.to_integer()
  end
  defp format_value(value) when is_float(value), do: round(value)
  defp format_value(value) when is_integer(value), do: value
  defp format_value(_), do: 0
end
