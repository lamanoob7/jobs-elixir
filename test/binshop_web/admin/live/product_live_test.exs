defmodule BinshopWeb.Admin.ProductLiveTest do
  use BinshopWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Binshop.Categories
  alias Binshop.Products
  alias Binshop.Products.ProductCategory

  @create_attrs_form %{
    description: "some product description",
    is_visible: true,
    name: "some product name",
    price: 120.5,
    price_without_vat: 120.5,
    vat: 120.5
  }

  @create_attrs %{
    description: "some product description",
    is_deleted: false,
    is_visible: true,
    name: "some product name",
    price: 120.5,
    price_without_vat: 120.5,
    vat: 120.5
  }

  @update_attrs %{
    description: "some product updated description",
    is_visible: false,
    name: "some updated name",
    price: 456.7,
    price_without_vat: 456.7,
    vat: 456.7
  }
  @invalid_attrs %{
    description: nil,
    is_visible: false,
    name: nil,
    price: nil,
    price_without_vat: nil,
    vat: nil
  }

  describe "Index" do
    setup [:create_product, :register_and_log_in_user]

    test "lists all products", %{conn: conn, product: product} do
      {:ok, _index_live, html} = live(conn, Routes.admin_product_index_path(conn, :index))

      assert html =~ "Listing Products"
      assert html =~ product.description
    end

    test "saves new product", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_product_index_path(conn, :index))

      assert index_live |> element("a", "New Product") |> render_click() =~
               "New Product"

      assert_patch(index_live, Routes.admin_product_index_path(conn, :new))

      assert index_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#product-form", product: @create_attrs_form)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.admin_product_index_path(conn, :index, sort: "name", page: 1, page_size: 20)
        )

      assert html =~ "Product created successfully"
      assert html =~ "some product description"
    end

    test "updates product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, Routes.admin_product_index_path(conn, :index))

      assert index_live |> element("#product-#{product.id} a", "Edit") |> render_click() =~
               "Edit Product"

      assert_patch(index_live, Routes.admin_product_index_path(conn, :edit, product))

      assert index_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#product-form", product: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.admin_product_index_path(conn, :index, sort: "name", page: 1, page_size: 20)
        )

      assert html =~ "Product updated successfully"
      assert html =~ "some product updated description"
    end

    test "deletes product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, Routes.admin_product_index_path(conn, :index))

      assert index_live |> element("#product-#{product.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#product-#{product.id}")
    end
  end

  describe "Show" do
    setup [:create_product, :register_and_log_in_user]

    test "displays product", %{conn: conn, product: product} do
      {:ok, _show_live, html} = live(conn, Routes.admin_product_show_path(conn, :show, product))

      assert html =~ "Show Product"
      assert html =~ product.description
    end

    test "updates product within modal", %{conn: conn, product: product} do
      {:ok, show_live, _html} = live(conn, Routes.admin_product_show_path(conn, :show, product))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Product"

      assert_patch(show_live, Routes.admin_product_show_path(conn, :edit, product))

      assert show_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#product-form", product: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_product_show_path(conn, :show, product))

      assert html =~ "Product updated successfully"
      assert html =~ "some product updated description"
    end

    test "assign product into category within modal", %{conn: conn, product: product} do
      category = fixture(:category)

      {:ok, show_live, _html} = live(conn, Routes.admin_product_show_path(conn, :show, product))

      assert show_live |> element("a", "Insert into category") |> render_click() =~
               "Add into Category"

      assert_patch(show_live, Routes.admin_product_show_path(conn, :add_category, product))

      assert show_live
             |> form("#product_category-form",
               product_category: %{
                 product_id: product.id,
                 category_id: nil
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
            product_id: product.id,
            category_id: category.id
          }
        )
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_product_show_path(conn, :show, product))

      assert %ProductCategory{} = Products.get_product_category!(category.id, product.id)

      assert html =~ "Product category created successfully"
      assert html =~ "Show Product"
      assert html =~ product.name
      assert html =~ category.name
    end
  end

  #########################
  ##### PRIVATE FUNCTIONS
  defp create_product(_) do
    product = fixture(:product)
    %{product: product}
  end

  defp fixture(:product) do
    {:ok, product} = Products.create_product(@create_attrs)
    product
  end

  defp fixture(:category) do
    {:ok, category} =
      Categories.create_category(%{
        description: "some category description",
        is_deleted: false,
        is_visible: true,
        name: "some category name"
      })

    category
  end
end
