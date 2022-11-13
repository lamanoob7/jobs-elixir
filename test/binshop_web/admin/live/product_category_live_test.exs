defmodule BinshopWeb.Admin.ProductCategoryLiveTest do
  use BinshopWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Binshop.Categories
  alias Binshop.Products

  @invalid_attrs %{category_id: nil, product_id: nil}

  describe "Index" do
    setup [:create_product_category, :register_and_log_in_user]

    test "lists all product_categories", %{conn: conn, product_category: product_category} do
      {:ok, _index_live, html} =
        live(conn, Routes.admin_product_category_index_path(conn, :index))

      assert html =~ "Listing Product categories"
      assert html =~ product_category.category.name
      assert html =~ product_category.product.name
    end

    test "saves new product_category", %{conn: conn} do
      new_category = create_category(%{name: "saves new product_category category"})
      new_product = create_product(%{name: "saves new product_category product"})

      {:ok, index_live, _html} =
        live(conn, Routes.admin_product_category_index_path(conn, :index))

      assert index_live |> element("a", "New Product category") |> render_click() =~
               "New Product category"

      assert_patch(index_live, Routes.admin_product_category_index_path(conn, :new))

      assert index_live
             |> form("#product_category-form", product_category: @invalid_attrs)
             |> render_change() =~ "<option value=\"\">Select product</option>"

      {:ok, _, html} =
        index_live
        |> form("#product_category-form",
          product_category: %{category_id: new_category.id, product_id: new_product.id}
        )
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.admin_product_category_index_path(conn, :index, page: 1, page_size: 20)
        )

      assert html =~ "Product category created successfully"
    end

    test "updates product_category in listing", %{conn: conn, product_category: product_category} do
      new_category = create_category(%{name: "updates product_category in listing category"})
      new_product = create_product(%{name: "updates product_category in listing product"})

      {:ok, index_live, _html} =
        live(conn, Routes.admin_product_category_index_path(conn, :index))

      assert index_live
             |> element("#product_category-#{product_category.id} a", "Edit")
             |> render_click() =~
               "Edit Product category"

      assert_patch(
        index_live,
        Routes.admin_product_category_index_path(conn, :edit, product_category)
      )

      assert index_live
             |> form("#product_category-form", product_category: @invalid_attrs)
             |> render_change() =~ "<option value=\"\">Select product</option>"

      {:ok, _, html} =
        index_live
        |> form("#product_category-form",
          product_category: %{category_id: new_category.id, product_id: new_product.id}
        )
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.admin_product_category_index_path(conn, :index, page: 1, page_size: 20)
        )

      assert html =~ "Product category updated successfully"
    end

    test "deletes product_category in listing", %{conn: conn, product_category: product_category} do
      {:ok, index_live, _html} =
        live(conn, Routes.admin_product_category_index_path(conn, :index))

      assert index_live
             |> element("#product_category-#{product_category.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#product_category-#{product_category.id}")
    end
  end

  describe "Show" do
    setup [:create_product_category, :register_and_log_in_user]

    test "displays product_category", %{conn: conn, product_category: product_category} do
      {:ok, _show_live, html} =
        live(conn, Routes.admin_product_category_show_path(conn, :show, product_category))

      assert html =~ "Show Product category"
    end

    test "updates product_category within modal", %{
      conn: conn,
      product_category: product_category
    } do
      new_category = create_category(%{name: "updates product_category within modal category"})
      new_product = create_product(%{name: "updates product_category within modal product"})

      {:ok, show_live, _html} =
        live(conn, Routes.admin_product_category_show_path(conn, :show, product_category))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Product category"

      assert_patch(
        show_live,
        Routes.admin_product_category_show_path(conn, :edit, product_category)
      )

      assert show_live
             |> form("#product_category-form", product_category: @invalid_attrs)
             |> render_change() =~ "<option value=\"\">Select product</option>"

      {:ok, _, html} =
        show_live
        |> form("#product_category-form",
          product_category: %{category_id: new_category.id, product_id: new_product.id}
        )
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.admin_product_category_show_path(conn, :show, product_category)
        )

      assert html =~ "Product category updated successfully"
    end
  end

  #################
  # PRIVATE FUNCTIONS
  defp create_category(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        is_deleted: false,
        is_visible: true,
        name: "some name"
      })
      |> Categories.create_category()

    category
  end

  defp create_product(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        is_deleted: true,
        is_visible: true,
        name: "some name",
        price: 120.5,
        price_without_vat: 120.5,
        vat: 120.5
      })
      |> Products.create_product()

    product
  end

  defp fixture(:product_category) do
    category = create_category()
    product = create_product()

    {:ok, product_category} =
      Products.create_product_category(%{category_id: category.id, product_id: product.id})

    Products.get_product_category!(product_category.id)
  end

  defp create_product_category(_) do
    product_category = fixture(:product_category)
    %{product_category: product_category}
  end
end
