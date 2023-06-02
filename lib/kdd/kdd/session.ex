defmodule Kdd.Kdd.Session do
  use Kdd.Model

  schema "sessions" do
    belongs_to :user, Kdd.Kdd.User

    field :token, :string

    timestamps()
  end

  @doc false
  def set_token(session, token) do
    session
    |> change(token: token)
  end
end
