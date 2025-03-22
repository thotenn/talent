defmodule Talent.Competitions.Judge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "judges" do
    field :name, :string

    belongs_to :user, Talent.Accounts.User
    many_to_many :categories, Talent.Competitions.Category, join_through: Talent.Competitions.CategoryJudge
    has_many :scores, Talent.Scoring.Score

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(judge, attrs) do
    judge
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> unique_constraint(:user_id)
  end
end
