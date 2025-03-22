defmodule Talent.DashboardTest do
  use Talent.DataCase

  alias Talent.Dashboard

  describe "dashboard_infos" do
    alias Talent.Dashboard.DashboardInfo

    import Talent.DashboardFixtures

    @invalid_attrs %{}

    test "list_dashboard_infos/0 returns all dashboard_infos" do
      dashboard_info = dashboard_info_fixture()
      assert Dashboard.list_dashboard_infos() == [dashboard_info]
    end

    test "get_dashboard_info!/1 returns the dashboard_info with given id" do
      dashboard_info = dashboard_info_fixture()
      assert Dashboard.get_dashboard_info!(dashboard_info.id) == dashboard_info
    end

    test "create_dashboard_info/1 with valid data creates a dashboard_info" do
      valid_attrs = %{}

      assert {:ok, %DashboardInfo{} = dashboard_info} = Dashboard.create_dashboard_info(valid_attrs)
    end

    test "create_dashboard_info/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_dashboard_info(@invalid_attrs)
    end

    test "update_dashboard_info/2 with valid data updates the dashboard_info" do
      dashboard_info = dashboard_info_fixture()
      update_attrs = %{}

      assert {:ok, %DashboardInfo{} = dashboard_info} = Dashboard.update_dashboard_info(dashboard_info, update_attrs)
    end

    test "update_dashboard_info/2 with invalid data returns error changeset" do
      dashboard_info = dashboard_info_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_dashboard_info(dashboard_info, @invalid_attrs)
      assert dashboard_info == Dashboard.get_dashboard_info!(dashboard_info.id)
    end

    test "delete_dashboard_info/1 deletes the dashboard_info" do
      dashboard_info = dashboard_info_fixture()
      assert {:ok, %DashboardInfo{}} = Dashboard.delete_dashboard_info(dashboard_info)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_dashboard_info!(dashboard_info.id) end
    end

    test "change_dashboard_info/1 returns a dashboard_info changeset" do
      dashboard_info = dashboard_info_fixture()
      assert %Ecto.Changeset{} = Dashboard.change_dashboard_info(dashboard_info)
    end
  end
end
