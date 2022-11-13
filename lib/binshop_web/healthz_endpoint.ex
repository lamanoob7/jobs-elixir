defmodule BinshopWeb.HealthzEndpoint do
  @moduledoc """
  Healthz module endpoint to run on different port with different session settings.
  """

  use Phoenix.Endpoint, otp_app: :binshop

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_binshop_healthz_key",
    signing_salt: "eR61r757"
  ]

  socket "/socket", BinshopWeb.Web.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :binshop
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger_healthz",
    cookie_key: "request_logger_healthz"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Session, @session_options
  plug BinshopWeb.Healthz.Router
end
