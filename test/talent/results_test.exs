defmodule Talent.ResultsTest do
  use Talent.DataCase

  alias Talent.Results

  describe "results" do
    alias Talent.Results.ResultsLive

    import Talent.ResultsFixtures

    @invalid_attrs %{category_id: nil}

    test "list_results/0 returns all results" do
      results_live = results_live_fixture()
      assert Results.list_results() == [results_live]
    end

    test "get_results_live!/1 returns the results_live with given id" do
      results_live = results_live_fixture()
      assert Results.get_results_live!(results_live.id) == results_live
    end

    test "create_results_live/1 with valid data creates a results_live" do
      valid_attrs = %{category_id: 42}

      assert {:ok, %ResultsLive{} = results_live} = Results.create_results_live(valid_attrs)
      assert results_live.category_id == 42
    end

    test "create_results_live/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Results.create_results_live(@invalid_attrs)
    end

    test "update_results_live/2 with valid data updates the results_live" do
      results_live = results_live_fixture()
      update_attrs = %{category_id: 43}

      assert {:ok, %ResultsLive{} = results_live} = Results.update_results_live(results_live, update_attrs)
      assert results_live.category_id == 43
    end

    test "update_results_live/2 with invalid data returns error changeset" do
      results_live = results_live_fixture()
      assert {:error, %Ecto.Changeset{}} = Results.update_results_live(results_live, @invalid_attrs)
      assert results_live == Results.get_results_live!(results_live.id)
    end

    test "delete_results_live/1 deletes the results_live" do
      results_live = results_live_fixture()
      assert {:ok, %ResultsLive{}} = Results.delete_results_live(results_live)
      assert_raise Ecto.NoResultsError, fn -> Results.get_results_live!(results_live.id) end
    end

    test "change_results_live/1 returns a results_live changeset" do
      results_live = results_live_fixture()
      assert %Ecto.Changeset{} = Results.change_results_live(results_live)
    end
  end
end
