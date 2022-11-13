defmodule BinshopWeb.Common.Components.ModalComponent do
  @moduledoc """
  Modal component
  """
  use BinshopWeb, :live_component

  alias Surface.Components.LivePatch

  prop return_to, :string, required: true

  slot default, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <div id={@id} class="phx-modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target={@id}
      phx-page-loading>

      <div class="phx-modal-content">
        <LivePatch label="My link" to={@return_to} class="phx-modal-close">{raw("&times;")}</LivePatch>
        <#slot />
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
