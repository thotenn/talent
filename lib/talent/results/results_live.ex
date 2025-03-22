defmodule Talent.Results.ResultsLive do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :category_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(results_live, attrs) do
    results_live
    |> cast(attrs, [:category_id])
    |> validate_required([:category_id])
  end
end
