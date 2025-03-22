defmodule Talent.ScoringTest do
  use Talent.DataCase

  alias Talent.Scoring

  describe "scoring_criteria" do
    alias Talent.Scoring.ScoringCriterion

    import Talent.ScoringFixtures

    @invalid_attrs %{name: nil, description: nil, max_points: nil}

    test "list_scoring_criteria/0 returns all scoring_criteria" do
      scoring_criterion = scoring_criterion_fixture()
      assert Scoring.list_scoring_criteria() == [scoring_criterion]
    end

    test "get_scoring_criterion!/1 returns the scoring_criterion with given id" do
      scoring_criterion = scoring_criterion_fixture()
      assert Scoring.get_scoring_criterion!(scoring_criterion.id) == scoring_criterion
    end

    test "create_scoring_criterion/1 with valid data creates a scoring_criterion" do
      valid_attrs = %{name: "some name", description: "some description", max_points: 42}

      assert {:ok, %ScoringCriterion{} = scoring_criterion} = Scoring.create_scoring_criterion(valid_attrs)
      assert scoring_criterion.name == "some name"
      assert scoring_criterion.description == "some description"
      assert scoring_criterion.max_points == 42
    end

    test "create_scoring_criterion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scoring.create_scoring_criterion(@invalid_attrs)
    end

    test "update_scoring_criterion/2 with valid data updates the scoring_criterion" do
      scoring_criterion = scoring_criterion_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", max_points: 43}

      assert {:ok, %ScoringCriterion{} = scoring_criterion} = Scoring.update_scoring_criterion(scoring_criterion, update_attrs)
      assert scoring_criterion.name == "some updated name"
      assert scoring_criterion.description == "some updated description"
      assert scoring_criterion.max_points == 43
    end

    test "update_scoring_criterion/2 with invalid data returns error changeset" do
      scoring_criterion = scoring_criterion_fixture()
      assert {:error, %Ecto.Changeset{}} = Scoring.update_scoring_criterion(scoring_criterion, @invalid_attrs)
      assert scoring_criterion == Scoring.get_scoring_criterion!(scoring_criterion.id)
    end

    test "delete_scoring_criterion/1 deletes the scoring_criterion" do
      scoring_criterion = scoring_criterion_fixture()
      assert {:ok, %ScoringCriterion{}} = Scoring.delete_scoring_criterion(scoring_criterion)
      assert_raise Ecto.NoResultsError, fn -> Scoring.get_scoring_criterion!(scoring_criterion.id) end
    end

    test "change_scoring_criterion/1 returns a scoring_criterion changeset" do
      scoring_criterion = scoring_criterion_fixture()
      assert %Ecto.Changeset{} = Scoring.change_scoring_criterion(scoring_criterion)
    end
  end

  describe "scores" do
    alias Talent.Scoring.Score

    import Talent.ScoringFixtures

    @invalid_attrs %{value: nil}

    test "list_scores/0 returns all scores" do
      score = score_fixture()
      assert Scoring.list_scores() == [score]
    end

    test "get_score!/1 returns the score with given id" do
      score = score_fixture()
      assert Scoring.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score" do
      valid_attrs = %{value: 120.5}

      assert {:ok, %Score{} = score} = Scoring.create_score(valid_attrs)
      assert score.value == 120.5
    end

    test "create_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scoring.create_score(@invalid_attrs)
    end

    test "update_score/2 with valid data updates the score" do
      score = score_fixture()
      update_attrs = %{value: 456.7}

      assert {:ok, %Score{} = score} = Scoring.update_score(score, update_attrs)
      assert score.value == 456.7
    end

    test "update_score/2 with invalid data returns error changeset" do
      score = score_fixture()
      assert {:error, %Ecto.Changeset{}} = Scoring.update_score(score, @invalid_attrs)
      assert score == Scoring.get_score!(score.id)
    end

    test "delete_score/1 deletes the score" do
      score = score_fixture()
      assert {:ok, %Score{}} = Scoring.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> Scoring.get_score!(score.id) end
    end

    test "change_score/1 returns a score changeset" do
      score = score_fixture()
      assert %Ecto.Changeset{} = Scoring.change_score(score)
    end
  end

  describe "scoring" do
    alias Talent.Scoring.ScoringLive

    import Talent.ScoringFixtures

    @invalid_attrs %{judge_id: nil}

    test "list_scoring/0 returns all scoring" do
      scoring_live = scoring_live_fixture()
      assert Scoring.list_scoring() == [scoring_live]
    end

    test "get_scoring_live!/1 returns the scoring_live with given id" do
      scoring_live = scoring_live_fixture()
      assert Scoring.get_scoring_live!(scoring_live.id) == scoring_live
    end

    test "create_scoring_live/1 with valid data creates a scoring_live" do
      valid_attrs = %{judge_id: 42}

      assert {:ok, %ScoringLive{} = scoring_live} = Scoring.create_scoring_live(valid_attrs)
      assert scoring_live.judge_id == 42
    end

    test "create_scoring_live/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scoring.create_scoring_live(@invalid_attrs)
    end

    test "update_scoring_live/2 with valid data updates the scoring_live" do
      scoring_live = scoring_live_fixture()
      update_attrs = %{judge_id: 43}

      assert {:ok, %ScoringLive{} = scoring_live} = Scoring.update_scoring_live(scoring_live, update_attrs)
      assert scoring_live.judge_id == 43
    end

    test "update_scoring_live/2 with invalid data returns error changeset" do
      scoring_live = scoring_live_fixture()
      assert {:error, %Ecto.Changeset{}} = Scoring.update_scoring_live(scoring_live, @invalid_attrs)
      assert scoring_live == Scoring.get_scoring_live!(scoring_live.id)
    end

    test "delete_scoring_live/1 deletes the scoring_live" do
      scoring_live = scoring_live_fixture()
      assert {:ok, %ScoringLive{}} = Scoring.delete_scoring_live(scoring_live)
      assert_raise Ecto.NoResultsError, fn -> Scoring.get_scoring_live!(scoring_live.id) end
    end

    test "change_scoring_live/1 returns a scoring_live changeset" do
      scoring_live = scoring_live_fixture()
      assert %Ecto.Changeset{} = Scoring.change_scoring_live(scoring_live)
    end
  end
end
