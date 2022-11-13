defmodule BinshopWeb.Admin.Router do
  defmacro __using__(_ \\ []) do
    quote do
      require BinshopWeb.Admin.Router
      alias BinshopWeb.Admin.Router, as: AdminRoutes
    end
  end

  defmacro routes do
    quote do
      scope "/admin", BinshopWeb.Admin, as: :admin do
        pipe_through [:browser, :require_authenticated_user, :require_managing_policy]

        live "/", PageLive, :index

        # resources "/users", UserController

        scope "/categories", CategoryLive do
          live "/", Index, :index
          live "/new", Index, :new
          live "/:id/edit", Index, :edit

          live "/:id", Show, :show
          live "/:id/show/edit", Show, :edit
          live "/:id/show/add_category", Show, :add_category
        end

        scope "/products", ProductLive do
          live "/", Index, :index
          live "/new", Index, :new
          live "/:id/edit", Index, :edit

          live "/:id", Show, :show
          live "/:id/show/edit", Show, :edit
          live "/:id/show/add_category", Show, :add_category
        end

        scope "/product_categories", ProductCategoryLive do
          live "/", Index, :index
          live "/new", Index, :new
          live "/:id/edit", Index, :edit

          live "/:id", Show, :show
          live "/:id/show/edit", Show, :edit
        end
      end
    end
  end
end
