defmodule Kdd.Repo do
  use Ecto.Repo,
    otp_app: :kdd,
    adapter: Ecto.Adapters.Postgres
end
