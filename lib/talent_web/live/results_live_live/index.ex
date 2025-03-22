defmodule TalentWeb.ResultsLive.Index do
  use TalentWeb, :live_view

  alias Talent.Competitions

  on_mount {TalentWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    categories = Competitions.list_categories()

    {:ok, socket
      |> assign(:categories, categories)
      |> assign(:page_title, "Resultados de la Competencia")
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Resultados de la Competencia")
  end
end
