defmodule Proofwith.Organizations.Organization do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Proofwith.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :meta, :map
    belongs_to :user, User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(organization, attrs, user_scope) do
    organization
    |> cast(attrs, [:name, :slug, :meta])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
    |> put_change(:user_id, user_scope.user.id)
  end
end
