defmodule TalentWeb.ScoringLive.Index do
  use TalentWeb, :live_view

  alias Talent.Competitions
  alias Talent.Repo
  # alias Talent.Competitions.{Judge, Category, Participant}

  # Mantén solo los alias que realmente estás usando
  # Por ejemplo, si solo usas Judge
  # alias Talent.Competitions.Judge

  on_mount {TalentWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    # Obtener el juez asociado con el usuario actual
    judge = Competitions.get_judge_by_user_id(current_user.id)

    if judge do
      # Obtener las categorías asignadas al juez - Precargar la relación
      judge_with_categories = Repo.preload(judge, :categories)

      if Enum.empty?(judge_with_categories.categories) do
        {:ok, socket
          |> put_flash(:info, "No tienes categorías asignadas. Contacta al administrador.")
          |> assign(:judge, judge)
          |> assign(:categories, [])
          |> assign(:selected_category, nil)
          |> assign(:participants, [])
        }
      else
        {:ok, socket
          |> assign(:judge, judge)
          |> assign(:categories, judge_with_categories.categories)
          |> assign(:selected_category, nil)
          |> assign(:participants, [])
        }
      end
    else
      {:ok, socket
        |> put_flash(:error, "No tienes un perfil de juez asignado")
        |> redirect(to: ~p"/")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Panel de Calificaciones")
  end

  @impl true
  def handle_event("select-category", %{"category_id" => category_id}, socket) do
    category_id = String.to_integer(category_id)
    category = Enum.find(socket.assigns.categories, &(&1.id == category_id))

    participants =
      if category do
        Competitions.list_participants_by_category(category_id)
      else
        []
      end

    {:noreply, socket
      |> assign(:selected_category, category)
      |> assign(:participants, participants)
    }
  end
end
