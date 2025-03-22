defmodule TalentWeb.ScoringLive.Show do
  use TalentWeb, :live_view

  on_mount {TalentWeb.UserAuth, :ensure_authenticated}

  alias Talent.Competitions
  alias Talent.Scoring
  # alias Talent.Scoring.Score

  @impl true
  def mount(%{"participant_id" => participant_id}, _session, socket) do
    current_user = socket.assigns.current_user
    judge = Competitions.get_judge_by_user_id(current_user.id)

    if judge do
      participant = Competitions.get_participant!(participant_id) |> Talent.Repo.preload(:category)
      category = participant.category

      # Verificar si el juez está asignado a esta categoría
      is_assigned = Competitions.judge_assigned_to_category?(judge.id, category.id)

      if is_assigned do
        # Obtener los criterios de evaluación para esta categoría
        criteria = Scoring.list_root_scoring_criteria_by_category(category.id)

        # Obtener las puntuaciones existentes del juez para este participante
        existing_scores = Scoring.get_judge_scores_for_participant(judge.id, participant.id)
        |> Enum.group_by(fn score -> score.criterion_id end)

        # Inicializar el formulario
        scores_form = init_scores_form(criteria, existing_scores)

        {:ok, socket
          |> assign(:judge, judge)
          |> assign(:participant, participant)
          |> assign(:category, category)
          |> assign(:criteria, criteria)
          |> assign(:scores_form, scores_form)
          |> assign(:page_title, "Calificar a #{participant.name}")
        }
      else
        {:ok, socket
          |> put_flash(:error, "No estás asignado a la categoría de este participante")
          |> redirect(to: ~p"/jury/scoring")}
      end
    else
      {:ok, socket
        |> put_flash(:error, "No tienes un perfil de juez asignado")
        |> redirect(to: ~p"/")}
    end
  end

  @impl true
  def handle_event("save-scores", %{"scores" => scores_params}, socket) do
    judge = socket.assigns.judge
    participant = socket.assigns.participant

    results =
      Enum.map(scores_params, fn {criterion_id, value} ->
        criterion_id = String.to_integer(criterion_id)
        value =
          case Float.parse(value) do
            {val, _} -> val
            :error -> 0.0
          end

        score_params = %{
          judge_id: judge.id,
          participant_id: participant.id,
          criterion_id: criterion_id,
          value: value
        }

        case Scoring.upsert_score(score_params) do
          {:ok, score} -> {:ok, score}
          {:error, changeset} -> {:error, criterion_id, changeset}
        end
      end)

    errors = Enum.filter(results, fn
      {:error, _, _} -> true
      _ -> false
    end)

    if Enum.empty?(errors) do
      # Recalcular el formulario con las nuevas puntuaciones
      # existing_scores = Scoring.get_judge_scores_for_participant(judge.id, participant.id)
      # |> Enum.group_by(fn score -> score.criterion_id end)

      # scores_form = init_scores_form(socket.assigns.criteria, existing_scores)

      {:noreply, socket
        |> put_flash(:info, "Puntuaciones guardadas correctamente")
        |> push_navigate(to: ~p"/jury/scoring?category_id=#{participant.category_id}")
      }
    else
      {:noreply, socket
        |> put_flash(:error, "Hubo errores al guardar las puntuaciones")
      }
    end
  end

  defp init_scores_form(criteria, existing_scores) do
    # Para cada criterio, inicializar con el valor existente o 0
    Enum.reduce(criteria, %{}, fn criterion, acc ->
      root_value =
        case Map.get(existing_scores, criterion.id) do
          [score | _] -> score.value
          _ -> 0.0
        end

      # Para cada subcriterio, hacer lo mismo
      sub_scores =
        Enum.reduce(criterion.sub_criteria, %{}, fn sub, sub_acc ->
          sub_value =
            case Map.get(existing_scores, sub.id) do
              [score | _] -> score.value
              _ -> 0.0
            end

          Map.put(sub_acc, sub.id, sub_value)
        end)

      Map.put(acc, criterion.id, %{
        value: root_value,
        sub_criteria: sub_scores
      })
    end)
  end
end
