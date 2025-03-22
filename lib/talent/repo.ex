defmodule Talent.Repo do
  use Ecto.Repo,
    otp_app: :talent,
    adapter: Ecto.Adapters.Postgres
end
