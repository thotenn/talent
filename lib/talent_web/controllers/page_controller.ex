defmodule TalentWeb.PageController do
  use TalentWeb, :controller

  def home(conn, _params) do
    # Si el usuario está autenticado, redirigir al dashboard
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/dashboard")
    else
      redirect(conn, to: ~p"/users/log_in")
    end
  end
end
