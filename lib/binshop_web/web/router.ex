defmodule BinshopWeb.Web.Router do
  defmacro __using__(_ \\ []) do
    quote do
      require BinshopWeb.Web.Router

      alias BinshopWeb.Web.Router, as: WebRoutes
    end
  end

  defmacro routes do
    quote do
      pipeline :web do
        plug BinshopWeb.Plugs.EnsureBasketSession
        plug :put_root_layout, {BinshopWeb.Web.LayoutView, :root}
      end

      scope "/", BinshopWeb.Web do
        pipe_through [:browser, :web]

        live "/", PageLive, :index

        scope "/basket", BasketLive do
          live "/", Index, :index
        end

        scope "/categories", CategoryLive do
          live "/", Index, :index
          live "/:slug", Show, :show
        end

        scope "/products", ProductLive do
          live "/", Index, :index
          live "/:slug", Show, :show
        end
      end

      scope "/errors", BinshopWeb.Web do
        scope "/html" do
          pipe_through [:browser]

          get "/", TestController, :index
          get "/bad-request", TestController, :bad_request
          get "/unauthorized", TestController, :unauthorized
          get "/forbidden", TestController, :forbidden
          get "/not-found", TestController, :not_found
          get "/unprocessable-entity", TestController, :unprocessable_entity
          get "/internal-server-error", TestController, :internal_server_error
        end

        scope "/json" do
          pipe_through [:api]

          get "/", TestController, :index
          get "/bad-request", TestController, :bad_request
          get "/unauthorized", TestController, :unauthorized
          get "/forbidden", TestController, :forbidden
          get "/not-found", TestController, :not_found
          get "/unprocessable-entity", TestController, :unprocessable_entity
          get "/internal-server-error", TestController, :internal_server_error
        end
      end
    end
  end
end
