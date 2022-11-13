defmodule Binshop.Mailer do
  @moduledoc """
  Binshop.Mailer uses :bamboo library to send emails
  """

  use Bamboo.Mailer, otp_app: :binshop
end
