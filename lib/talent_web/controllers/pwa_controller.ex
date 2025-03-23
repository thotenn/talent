defmodule TalentWeb.PwaController do
  use TalentWeb, :controller

  def install(conn, _params) do
    render(conn, :install)
  end
end
