defmodule TalentWeb.ScoringLiveLiveTest do
  use TalentWeb.ConnCase

  import Phoenix.LiveViewTest
  import Talent.ScoringFixtures

  @create_attrs %{judge_id: 42}
  @update_attrs %{judge_id: 43}
  @invalid_attrs %{judge_id: nil}

  defp create_scoring_live(_) do
    scoring_live = scoring_live_fixture()
    %{scoring_live: scoring_live}
  end

  describe "Index" do
    setup [:create_scoring_live]

    test "lists all scoring", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/scoring")

      assert html =~ "Listing Scoring"
    end

    test "saves new scoring_live", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/scoring")

      assert index_live |> element("a", "New Scoring live") |> render_click() =~
               "New Scoring live"

      assert_patch(index_live, ~p"/scoring/new")

      assert index_live
             |> form("#scoring_live-form", scoring_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#scoring_live-form", scoring_live: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/scoring")

      html = render(index_live)
      assert html =~ "Scoring live created successfully"
    end

    test "updates scoring_live in listing", %{conn: conn, scoring_live: scoring_live} do
      {:ok, index_live, _html} = live(conn, ~p"/scoring")

      assert index_live |> element("#scoring-#{scoring_live.id} a", "Edit") |> render_click() =~
               "Edit Scoring live"

      assert_patch(index_live, ~p"/scoring/#{scoring_live}/edit")

      assert index_live
             |> form("#scoring_live-form", scoring_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#scoring_live-form", scoring_live: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/scoring")

      html = render(index_live)
      assert html =~ "Scoring live updated successfully"
    end

    test "deletes scoring_live in listing", %{conn: conn, scoring_live: scoring_live} do
      {:ok, index_live, _html} = live(conn, ~p"/scoring")

      assert index_live |> element("#scoring-#{scoring_live.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#scoring-#{scoring_live.id}")
    end
  end

  describe "Show" do
    setup [:create_scoring_live]

    test "displays scoring_live", %{conn: conn, scoring_live: scoring_live} do
      {:ok, _show_live, html} = live(conn, ~p"/scoring/#{scoring_live}")

      assert html =~ "Show Scoring live"
    end

    test "updates scoring_live within modal", %{conn: conn, scoring_live: scoring_live} do
      {:ok, show_live, _html} = live(conn, ~p"/scoring/#{scoring_live}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Scoring live"

      assert_patch(show_live, ~p"/scoring/#{scoring_live}/show/edit")

      assert show_live
             |> form("#scoring_live-form", scoring_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#scoring_live-form", scoring_live: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/scoring/#{scoring_live}")

      html = render(show_live)
      assert html =~ "Scoring live updated successfully"
    end
  end
end
