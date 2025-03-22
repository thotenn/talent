defmodule TalentWeb.DashboardInfoLiveTest do
  use TalentWeb.ConnCase

  import Phoenix.LiveViewTest
  import Talent.DashboardFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_dashboard_info(_) do
    dashboard_info = dashboard_info_fixture()
    %{dashboard_info: dashboard_info}
  end

  describe "Index" do
    setup [:create_dashboard_info]

    test "lists all dashboard_infos", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/dashboard_infos")

      assert html =~ "Listing Dashboard infos"
    end

    test "saves new dashboard_info", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboard_infos")

      assert index_live |> element("a", "New Dashboard info") |> render_click() =~
               "New Dashboard info"

      assert_patch(index_live, ~p"/dashboard_infos/new")

      assert index_live
             |> form("#dashboard_info-form", dashboard_info: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#dashboard_info-form", dashboard_info: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/dashboard_infos")

      html = render(index_live)
      assert html =~ "Dashboard info created successfully"
    end

    test "updates dashboard_info in listing", %{conn: conn, dashboard_info: dashboard_info} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboard_infos")

      assert index_live |> element("#dashboard_infos-#{dashboard_info.id} a", "Edit") |> render_click() =~
               "Edit Dashboard info"

      assert_patch(index_live, ~p"/dashboard_infos/#{dashboard_info}/edit")

      assert index_live
             |> form("#dashboard_info-form", dashboard_info: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#dashboard_info-form", dashboard_info: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/dashboard_infos")

      html = render(index_live)
      assert html =~ "Dashboard info updated successfully"
    end

    test "deletes dashboard_info in listing", %{conn: conn, dashboard_info: dashboard_info} do
      {:ok, index_live, _html} = live(conn, ~p"/dashboard_infos")

      assert index_live |> element("#dashboard_infos-#{dashboard_info.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#dashboard_infos-#{dashboard_info.id}")
    end
  end

  describe "Show" do
    setup [:create_dashboard_info]

    test "displays dashboard_info", %{conn: conn, dashboard_info: dashboard_info} do
      {:ok, _show_live, html} = live(conn, ~p"/dashboard_infos/#{dashboard_info}")

      assert html =~ "Show Dashboard info"
    end

    test "updates dashboard_info within modal", %{conn: conn, dashboard_info: dashboard_info} do
      {:ok, show_live, _html} = live(conn, ~p"/dashboard_infos/#{dashboard_info}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Dashboard info"

      assert_patch(show_live, ~p"/dashboard_infos/#{dashboard_info}/show/edit")

      assert show_live
             |> form("#dashboard_info-form", dashboard_info: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#dashboard_info-form", dashboard_info: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/dashboard_infos/#{dashboard_info}")

      html = render(show_live)
      assert html =~ "Dashboard info updated successfully"
    end
  end
end
