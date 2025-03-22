defmodule TalentWeb.ResultsLiveLiveTest do
  use TalentWeb.ConnCase

  import Phoenix.LiveViewTest
  import Talent.ResultsFixtures

  @create_attrs %{category_id: 42}
  @update_attrs %{category_id: 43}
  @invalid_attrs %{category_id: nil}

  defp create_results_live(_) do
    results_live = results_live_fixture()
    %{results_live: results_live}
  end

  describe "Index" do
    setup [:create_results_live]

    test "lists all results", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/results")

      assert html =~ "Listing Results"
    end

    test "saves new results_live", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/results")

      assert index_live |> element("a", "New Results live") |> render_click() =~
               "New Results live"

      assert_patch(index_live, ~p"/results/new")

      assert index_live
             |> form("#results_live-form", results_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#results_live-form", results_live: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/results")

      html = render(index_live)
      assert html =~ "Results live created successfully"
    end

    test "updates results_live in listing", %{conn: conn, results_live: results_live} do
      {:ok, index_live, _html} = live(conn, ~p"/results")

      assert index_live |> element("#results-#{results_live.id} a", "Edit") |> render_click() =~
               "Edit Results live"

      assert_patch(index_live, ~p"/results/#{results_live}/edit")

      assert index_live
             |> form("#results_live-form", results_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#results_live-form", results_live: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/results")

      html = render(index_live)
      assert html =~ "Results live updated successfully"
    end

    test "deletes results_live in listing", %{conn: conn, results_live: results_live} do
      {:ok, index_live, _html} = live(conn, ~p"/results")

      assert index_live |> element("#results-#{results_live.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#results-#{results_live.id}")
    end
  end

  describe "Show" do
    setup [:create_results_live]

    test "displays results_live", %{conn: conn, results_live: results_live} do
      {:ok, _show_live, html} = live(conn, ~p"/results/#{results_live}")

      assert html =~ "Show Results live"
    end

    test "updates results_live within modal", %{conn: conn, results_live: results_live} do
      {:ok, show_live, _html} = live(conn, ~p"/results/#{results_live}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Results live"

      assert_patch(show_live, ~p"/results/#{results_live}/show/edit")

      assert show_live
             |> form("#results_live-form", results_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#results_live-form", results_live: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/results/#{results_live}")

      html = render(show_live)
      assert html =~ "Results live updated successfully"
    end
  end
end
