defmodule BinshopWeb.Admin.CategoryLiveTest do
  use BinshopWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Binshop.Categories
  alias Binshop.Products
  alias Binshop.Products.ProductCategory

  @create_attrs_form %{
    description: "some category create attr form description",
    is_visible: true,
    name: "some category create attr form name"
  }

  @create_attrs %{
    description: "some description",
    is_deleted: false,
    is_visible: true,
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    is_visible: false,
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, is_visible: false, name: nil}

  describe "Index" do
    setup [:create_category, :register_and_log_in_user]

    test "lists all categories", %{conn: conn, category: category} do
      {:ok, _index_live, html} = live(conn, Routes.admin_category_index_path(conn, :index))

      assert html =~ "Listing Categories"
      assert html =~ category.description
    end

    test "saves new category", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_category_index_path(conn, :index))

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert_patch(index_live, Routes.admin_category_index_path(conn, :new))

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#category-form", category: @create_attrs_form)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.admin_category_index_path(conn, :index, sort: "name", page: 1, page_size: 20)
        )

      assert html =~ "Category created successfully"
      assert html =~ "some category create attr form description"
    end

    test "updates category in listing", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, Routes.admin_category_index_path(conn, :index))

      assert index_live |> element("#category-#{category.id} a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(index_live, Routes.admin_category_index_path(conn, :edit, category))

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#category-form", category: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.admin_category_index_path(conn, :index, sort: "name", page: 1, page_size: 20)
        )

      assert html =~ "Category updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes category in listing", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, Routes.admin_category_index_path(conn, :index))

      assert index_live |> element("#category-#{category.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#category-#{category.id}")
    end
  end

  describe "Show" do
    setup [:create_category, :register_and_log_in_user]

    test "displays category", %{conn: conn, category: category} do
      {:ok, _show_live, html} = live(conn, Routes.admin_category_show_path(conn, :show, category))

      assert html =~ "Show Category"
      assert html =~ category.description
    end

    test "updates category within modal", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, Routes.admin_category_show_path(conn, :show, category))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(show_live, Routes.admin_category_show_path(conn, :edit, category))

      assert show_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#category-form", category: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_category_show_path(conn, :show, category))

      assert html =~ "Category updated successfully"
      assert html =~ "some updated description"
    end

    test "assign product into category within modal", %{conn: conn, category: category} do
      product = fixture(:product)

      {:ok, show_live, _html} = live(conn, Routes.admin_category_show_path(conn, :show, category))

      assert show_live |> element("a", "Add product into category") |> render_click() =~
               "Add Product"

      assert_patch(show_live, Routes.admin_category_show_path(conn, :add_category, category))

      assert show_live
             |> form("#product_category-form",
               product_category: %{
                 category_id: category.id,
                 product_id: nil
               }
             )
             |> render_change() =~ "can&#39;t be blank"

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_category!(category.id, product.id)
      end

      {:ok, _, html} =
        show_live
        |> form("#product_category-form",
          product_category: %{
            category_id: category.id,
            product_id: product.id
          }
        )
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_category_show_path(conn, :show, category))

      assert %ProductCategory{} = Products.get_product_category!(category.id, product.id)

      assert html =~ "Product category created successfully"
      assert html =~ "Show Category"
      assert html =~ product.name
      assert html =~ category.name
    end
  end

  #########################
  ##### PRIVATE FUNCTIONS
  defp create_category(_) do
    category = fixture(:category)
    %{category: category}
  end

  defp fixture(:category) do
    {:ok, category} = Categories.create_category(@create_attrs)
    category
  end

  defp fixture(:product) do
    {:ok, product} =
      Products.create_product(%{
        description: "some product description",
        is_deleted: false,
        is_visible: true,
        name: "some product name",
        price: 12.1,
        price_without_vat: 10,
        vat: 21
      })

    product
  end
end
