defmodule BinshopWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use BinshopWeb, :controller
      use BinshopWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: BinshopWeb.Web

      import Plug.Conn
      import BinshopWeb.Gettext
      import BinshopWeb.Common.ControllerHelpers
      alias BinshopWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/binshop_web/web/templates",
        namespace: BinshopWeb.Web

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def view_auth do
    quote do
      use Phoenix.View,
        root: "lib/binshop_web/auth/templates",
        namespace: BinshopWeb.Auth

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def view_common do
    quote do
      use Phoenix.View,
        root: "lib/binshop_web/common/templates",
        namespace: BinshopWeb.Common

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Surface.LiveView,
        layout: {BinshopWeb.Web.LayoutView, "live.html"}

      on_mount BinshopWeb.Auth.UserLiveAuth
      on_mount BinshopWeb.Plugs.EnsureBasketLive

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Surface.Component

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Surface.LiveComponent

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import BinshopWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import BinshopWeb.Common.ErrorHelpers
      import BinshopWeb.Gettext
      alias BinshopWeb.Router.Helpers, as: Routes
      alias BinshopWeb.Common.ErrorHelpers.{JSONAPIError, JSONAPIErrorSource}
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
