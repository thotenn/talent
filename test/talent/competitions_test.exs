defmodule Talent.CompetitionsTest do
  use Talent.DataCase

  alias Talent.Competitions

  describe "categories" do
    alias Talent.Competitions.Category

    import Talent.CompetitionsFixtures

    @invalid_attrs %{name: nil, description: nil, max_points: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Competitions.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Competitions.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", max_points: 42}

      assert {:ok, %Category{} = category} = Competitions.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.max_points == 42
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Competitions.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", max_points: 43}

      assert {:ok, %Category{} = category} = Competitions.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.max_points == 43
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Competitions.update_category(category, @invalid_attrs)
      assert category == Competitions.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Competitions.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Competitions.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Competitions.change_category(category)
    end
  end

  describe "judges" do
    alias Talent.Competitions.Judge

    import Talent.CompetitionsFixtures

    @invalid_attrs %{name: nil}

    test "list_judges/0 returns all judges" do
      judge = judge_fixture()
      assert Competitions.list_judges() == [judge]
    end

    test "get_judge!/1 returns the judge with given id" do
      judge = judge_fixture()
      assert Competitions.get_judge!(judge.id) == judge
    end

    test "create_judge/1 with valid data creates a judge" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Judge{} = judge} = Competitions.create_judge(valid_attrs)
      assert judge.name == "some name"
    end

    test "create_judge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Competitions.create_judge(@invalid_attrs)
    end

    test "update_judge/2 with valid data updates the judge" do
      judge = judge_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Judge{} = judge} = Competitions.update_judge(judge, update_attrs)
      assert judge.name == "some updated name"
    end

    test "update_judge/2 with invalid data returns error changeset" do
      judge = judge_fixture()
      assert {:error, %Ecto.Changeset{}} = Competitions.update_judge(judge, @invalid_attrs)
      assert judge == Competitions.get_judge!(judge.id)
    end

    test "delete_judge/1 deletes the judge" do
      judge = judge_fixture()
      assert {:ok, %Judge{}} = Competitions.delete_judge(judge)
      assert_raise Ecto.NoResultsError, fn -> Competitions.get_judge!(judge.id) end
    end

    test "change_judge/1 returns a judge changeset" do
      judge = judge_fixture()
      assert %Ecto.Changeset{} = Competitions.change_judge(judge)
    end
  end

  describe "category_judges" do
    alias Talent.Competitions.CategoryJudge

    import Talent.CompetitionsFixtures

    @invalid_attrs %{}

    test "list_category_judges/0 returns all category_judges" do
      category_judge = category_judge_fixture()
      assert Competitions.list_category_judges() == [category_judge]
    end

    test "get_category_judge!/1 returns the category_judge with given id" do
      category_judge = category_judge_fixture()
      assert Competitions.get_category_judge!(category_judge.id) == category_judge
    end

    test "create_category_judge/1 with valid data creates a category_judge" do
      valid_attrs = %{}

      assert {:ok, %CategoryJudge{} = category_judge} = Competitions.create_category_judge(valid_attrs)
    end

    test "create_category_judge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Competitions.create_category_judge(@invalid_attrs)
    end

    test "update_category_judge/2 with valid data updates the category_judge" do
      category_judge = category_judge_fixture()
      update_attrs = %{}

      assert {:ok, %CategoryJudge{} = category_judge} = Competitions.update_category_judge(category_judge, update_attrs)
    end

    test "update_category_judge/2 with invalid data returns error changeset" do
      category_judge = category_judge_fixture()
      assert {:error, %Ecto.Changeset{}} = Competitions.update_category_judge(category_judge, @invalid_attrs)
      assert category_judge == Competitions.get_category_judge!(category_judge.id)
    end

    test "delete_category_judge/1 deletes the category_judge" do
      category_judge = category_judge_fixture()
      assert {:ok, %CategoryJudge{}} = Competitions.delete_category_judge(category_judge)
      assert_raise Ecto.NoResultsError, fn -> Competitions.get_category_judge!(category_judge.id) end
    end

    test "change_category_judge/1 returns a category_judge changeset" do
      category_judge = category_judge_fixture()
      assert %Ecto.Changeset{} = Competitions.change_category_judge(category_judge)
    end
  end

  describe "participants" do
    alias Talent.Competitions.Participant

    import Talent.CompetitionsFixtures

    @invalid_attrs %{name: nil}

    test "list_participants/0 returns all participants" do
      participant = participant_fixture()
      assert Competitions.list_participants() == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      participant = participant_fixture()
      assert Competitions.get_participant!(participant.id) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Participant{} = participant} = Competitions.create_participant(valid_attrs)
      assert participant.name == "some name"
    end

    test "create_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Competitions.create_participant(@invalid_attrs)
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = participant_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Participant{} = participant} = Competitions.update_participant(participant, update_attrs)
      assert participant.name == "some updated name"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = participant_fixture()
      assert {:error, %Ecto.Changeset{}} = Competitions.update_participant(participant, @invalid_attrs)
      assert participant == Competitions.get_participant!(participant.id)
    end

    test "delete_participant/1 deletes the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{}} = Competitions.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Competitions.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = participant_fixture()
      assert %Ecto.Changeset{} = Competitions.change_participant(participant)
    end
  end
end
