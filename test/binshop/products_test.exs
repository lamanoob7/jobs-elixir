defmodule Binshop.ProductsTest do
  use Binshop.DataCase

  alias Binshop.Categories
  alias Binshop.Products
  alias Binshop.Products.ProductCategory

  describe "products" do
    alias Binshop.Products.Product

    @valid_attrs %{
      description: "some product create description",
      is_deleted: true,
      is_visible: true,
      name: "some product create name",
      price: 120.5,
      price_without_vat: 120.5,
      vat: 120.5
    }
    @update_attrs %{
      description: "some updated description",
      is_deleted: false,
      is_visible: false,
      name: "some updated name",
      price: 456.7,
      price_without_vat: 456.7,
      vat: 456.7
    }
    @invalid_attrs %{
      description: nil,
      is_deleted: nil,
      is_visible: nil,
      name: nil,
      price: nil,
      price_without_vat: nil,
      vat: nil
    }

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Products.create_product()

      product
    end

    test "list_products/0 returns all products" do
      product = product_fixture()

      assert Products.list_products() == %Scrivener.Page{
               entries: [product],
               page_number: 1,
               page_size: 30,
               total_entries: 1,
               total_pages: 1
             }
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Products.create_product(@valid_attrs)
      assert product.description == "some product create description"
      assert product.is_deleted == false
      assert product.is_visible == true
      assert product.name == "some product create name"
      assert product.price == 120.5
      assert product.price_without_vat == 120.5
      assert product.vat == 120.5
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Products.update_product(product, @update_attrs)
      assert product.description == "some updated description"
      assert product.is_deleted == false
      assert product.is_visible == false
      assert product.name == "some updated name"
      assert product.price == 456.7
      assert product.price_without_vat == 456.7
      assert product.vat == 456.7
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end

  describe "product_categories create" do
    test "create_product_category/1 with valid data creates a product_category" do
      category = create_category()
      product = create_product()

      assert {:ok, %ProductCategory{} = product_category} =
               Products.create_product_category(%{
                 category_id: category.id,
                 product_id: product.id
               })

      product_category = Products.get_product_category!(product_category.id)

      assert product_category.category.id == category.id
      assert product_category.product.id == product.id
    end

    test "create_product_category/1 with already used product category relationship returns error changeset" do
      product_category = product_category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Products.create_product_category(%{
                 category_id: product_category.category.id,
                 product_id: product_category.product.id
               })
    end
  end

  describe "product_categories" do
    setup _context do
      category = create_category()
      product = create_product()

      %{category: category, product: product}
    end

    test "list_product_categories/0 returns all product_categories" do
      product_category = product_category_fixture()
      product_category = Products.get_product_category!(product_category.id)

      assert Products.list_product_categories() == %Scrivener.Page{
               entries: [product_category],
               page_number: 1,
               page_size: 30,
               total_entries: 1,
               total_pages: 1
             }
    end

    test "get_product_category!/1 returns the product_category with given id" do
      product_category = product_category_fixture()
      product_category = Products.get_product_category!(product_category.id)
      assert Products.get_product_category!(product_category.id) == product_category
    end

    test "update_product_category/2 with valid data updates the product_category" do
      product_category = product_category_fixture()

      category = create_category(%{name: "some category update name"})
      product = create_product(%{name: "some product update name"})

      assert {:ok, %ProductCategory{} = product_category} =
               Products.update_product_category(product_category, %{
                 category_id: category.id,
                 product_id: product.id
               })

      product_category = Products.get_product_category!(product_category.id)

      assert product_category.category.id == category.id
      assert product_category.product.id == product.id
    end

    test "update_product_category/2 with already existed product category relationship returns error changeset" do
      product_category = product_category_fixture()

      category2 = create_category(%{name: "some category 2 update name"})
      product2 = create_product(%{name: "some product 2 update name"})

      _product_category2 =
        product_category_fixture(%{category_id: category2.id, product_id: product2.id})

      assert {:error, %Ecto.Changeset{}} =
               Products.update_product_category(product_category, %{
                 category_id: category2.id,
                 product_id: product2.id
               })

      assert product_category == Products.get_product_category!(product_category.id)
    end

    test "delete_product_category/1 deletes the product_category" do
      product_category = product_category_fixture()
      assert {:ok, %ProductCategory{}} = Products.delete_product_category(product_category)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product_category!(product_category.id)
      end
    end

    test "change_product_category/1 returns a product_category changeset" do
      product_category = product_category_fixture()
      assert %Ecto.Changeset{} = Products.change_product_category(product_category)
    end
  end

  #################
  # PRIVATE FUNCTIONS
  defp create_category(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some category description",
        is_deleted: false,
        is_visible: true,
        name: "some category name"
      })
      |> Categories.create_category()

    category
  end

  defp create_product(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some product description",
        is_deleted: true,
        is_visible: true,
        name: "some product name",
        price: 120.5,
        price_without_vat: 120.5,
        vat: 120.5
      })
      |> Products.create_product()

    product
  end

  def product_category_fixture(attrs \\ %{}) do
    category_id =
      if Map.has_key?(attrs, :category_id) do
        Map.get(
          attrs,
          :category_id
        )
      else
        create_category(name: "some product category category category name") |> Map.get(:id)
      end

    product_id =
      if Map.has_key?(attrs, :category_id) do
        Map.get(
          attrs,
          :product_id
        )
      else
        create_product(name: "some category category product name") |> Map.get(:id)
      end

    {:ok, product_category} =
      attrs
      |> Enum.into(%{
        category_id: category_id,
        product_id: product_id
      })
      |> Products.create_product_category()

    Products.get_product_category!(product_category.id)
  end
end
