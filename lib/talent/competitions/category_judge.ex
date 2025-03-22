defmodule Talent.Competitions.CategoryJudge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "category_judges" do

    field :category_id, :id
    field :judge_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category_judge, attrs) do
    category_judge
    |> cast(attrs, [:category_id, :judge_id])
    |> validate_required([:category_id, :judge_id])
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:judge_id)
    |> unique_constraint([:judge_id, :category_id])
  end
end
