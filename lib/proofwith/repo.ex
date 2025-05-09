defmodule Proofwith.Repo do
  use Ecto.Repo,
    otp_app: :proofwith,
    adapter: Ecto.Adapters.SQLite3
end
