defmodule TalentWeb.ResultsLive.Show do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Scoring
  alias Decimal

  @impl true
  def mount(%{"category_id" => category_id}, _session, socket) do
    # Suscribirse al canal de actualizaciones de puntuaciones
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Talent.PubSub, "scores:updates")
    end

    category_id = String.to_integer(category_id)
    category = Competitions.get_category!(category_id)
    participants = Competitions.list_participants_by_category(category.id)

    # Obtener jueces de esta categoría
    judges = Competitions.list_judges_by_category(category.id)

    # Obtener criterios de evaluación
    criteria = Scoring.list_root_scoring_criteria_by_category(category.id)

    # Para cada juez, obtener los criterios asignados
    judges_criteria = Enum.map(judges, fn judge ->
      criteria_ids = Scoring.list_criteria_for_judge_in_category(judge.id, category_id)
        |> Enum.map(&(&1.id))
      {judge.id, criteria_ids}
    end) |> Map.new()

    # Calcular resultados
    results = calculate_results(participants, judges, criteria, judges_criteria)

    {:ok, socket
      |> assign(:category_id, category_id)
      |> assign(:category, category)
      |> assign(:participants, participants)
      |> assign(:judges, judges)
      |> assign(:criteria, criteria)
      |> assign(:judges_criteria, judges_criteria)
      |> assign(:results, results)
      |> assign(:page_title, "Resultados: #{category.name}")
    }
  end

  defp calculate_results(participants, judges, criteria, judges_criteria) do
    Enum.map(participants, fn participant ->
      # Calcular puntaje total
      total_score = Scoring.calculate_total_score(participant.id)

      # Calcular puntajes por juez, considerando sólo los criterios asignados a cada juez
      judge_scores = Enum.map(judges, fn judge ->
        assigned_criteria_ids = Map.get(judges_criteria, judge.id, [])

        scores = if Enum.empty?(assigned_criteria_ids) do
          # Si no hay criterios específicamente asignados, usar todos los scores
          Scoring.get_judge_scores_for_participant(judge.id, participant.id)
        else
          # Filtrar sólo los scores de criterios asignados
          Scoring.get_judge_scores_for_participant(judge.id, participant.id)
          |> Enum.filter(fn score -> Enum.member?(assigned_criteria_ids, score.criterion_id) end)
        end

        judge_total = Enum.reduce(scores, 0, fn score, acc ->
          # Verificar si es descuento
          if score.criterion && score.criterion.is_discount do
            acc - score.value
          else
            acc + score.value
          end
        end)

        {judge.id, judge_total}
      end) |> Map.new()

      # Calcular puntajes por criterio (promedio entre jueces que tienen ese criterio asignado)
      criteria_scores = Enum.map(criteria, fn criterion ->
        # Filtrar los jueces que tienen este criterio asignado
        valid_judges = Enum.filter(judges, fn judge ->
          assigned_criteria_ids = Map.get(judges_criteria, judge.id, [])
          Enum.empty?(assigned_criteria_ids) || Enum.member?(assigned_criteria_ids, criterion.id)
        end)

        if Enum.empty?(valid_judges) do
          {criterion.id, 0}
        else
          avg_score = Scoring.calculate_average_score_by_criterion(participant.id, criterion.id)
          {criterion.id, avg_score}
        end
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

  @impl true
  def handle_info({:score_updated, %{category_id: updated_category_id}}, socket) do
    # Solo actualizar si la categoría actualizada es la que estamos viendo
    if updated_category_id == socket.assigns.category_id do
      # Recalcular los resultados con los datos actualizados
      participants = Competitions.list_participants_by_category(socket.assigns.category_id)
      judges = Competitions.list_judges_by_category(socket.assigns.category_id)
      criteria = Scoring.list_root_scoring_criteria_by_category(socket.assigns.category_id)

      # Para cada juez, obtener los criterios asignados
      judges_criteria = Enum.map(judges, fn judge ->
        criteria_ids = Scoring.list_criteria_for_judge_in_category(judge.id, socket.assigns.category_id)
          |> Enum.map(&(&1.id))
        {judge.id, criteria_ids}
      end) |> Map.new()

      updated_results = calculate_results(participants, judges, criteria, judges_criteria)

      {:noreply, socket |> assign(:results, updated_results)}
    else
      # Si no es la categoría que estamos viendo, no hacemos nada
      {:noreply, socket}
    end
  end

  # Función para manejar valores decimales
  defp format_value(value) when is_struct(value, Decimal) do
    # Primero redondea el valor decimal para no perder precisión
    Decimal.round(value, 0) |> Decimal.to_integer()
  end
  defp format_value(value) when is_float(value), do: round(value)
  defp format_value(value) when is_integer(value), do: value
  defp format_value(_), do: 0
end
