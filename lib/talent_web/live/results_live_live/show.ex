defmodule TalentWeb.ResultsLive.Show do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Scoring

  @impl true
  def mount(%{"category_id" => category_id}, _session, socket) do
    category = Competitions.get_category!(category_id)
    participants = Competitions.list_participants_by_category(category.id)

    # Obtener jueces de esta categoría
    judges = Competitions.list_judges_by_category(category.id)

    # Obtener criterios de evaluación
    criteria = Scoring.list_root_scoring_criteria_by_category(category.id)

    # Calcular resultados
    results = calculate_results(participants, judges, criteria)

    {:ok, socket
      |> assign(:category, category)
      |> assign(:participants, participants)
      |> assign(:judges, judges)
      |> assign(:criteria, criteria)
      |> assign(:results, results)
      |> assign(:page_title, "Resultados: #{category.name}")
    }
  end

  defp calculate_results(participants, judges, criteria) do
    Enum.map(participants, fn participant ->
      # Calcular puntaje total
      total_score = Scoring.calculate_total_score(participant.id)

      # Calcular puntajes por juez
      judge_scores = Enum.map(judges, fn judge ->
        scores = Scoring.get_judge_scores_for_participant(judge.id, participant.id)
        judge_total = Enum.reduce(scores, 0, fn score, acc -> acc + score.value end)
        {judge.id, judge_total}
      end) |> Map.new()

      # Calcular puntajes por criterio (promedio entre jueces)
      criteria_scores = Enum.map(criteria, fn criterion ->
        avg_score = Scoring.calculate_average_score_by_criterion(participant.id, criterion.id)
        {criterion.id, avg_score}
      end) |> Map.new()

      %{
        participant: participant,
        total_score: total_score,
        judge_scores: judge_scores,
        criteria_scores: criteria_scores
      }
    end)
    |> Enum.sort_by(fn result -> result.total_score end, :desc)
  end
end
