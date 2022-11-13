defmodule Binshop.CategoriesTest do
  use Binshop.DataCase

  alias Binshop.Categories

  describe "categories" do
    alias Binshop.Categories.Category

    @valid_attrs %{
      description: "some description",
      is_deleted: false,
      is_visible: true,
      name: "some name"
    }
    @update_attrs %{
      description: "some updated description",
      is_deleted: false,
      is_visible: false,
      name: "some updated name"
    }
    @invalid_attrs %{description: nil, is_deleted: nil, is_visible: nil, name: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Categories.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()

      assert Categories.list_categories() == %Scrivener.Page{
               entries: [category],
               page_number: 1,
               page_size: 30,
               total_entries: 1,
               total_pages: 1
             }
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Categories.get_category!(category.id) == category
    end

    test "get_category_by_slug!/1 returns the category with given id" do
      category = category_fixture()
      assert Categories.get_category_by_slug!(category.slug) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Categories.create_category(@valid_attrs)
      assert category.description == "some description"
      assert category.is_deleted == false
      assert category.is_visible == true
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Categories.update_category(category, @update_attrs)
      assert category.description == "some updated description"
      assert category.is_deleted == false
      assert category.is_visible == false
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Categories.update_category(category, @invalid_attrs)
      assert category == Categories.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Categories.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Categories.change_category(category)
    end
  end
end
