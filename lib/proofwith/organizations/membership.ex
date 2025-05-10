defmodule Proofwith.Organizations.Membership do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Proofwith.Accounts.User
  alias Proofwith.Organizations.Organization

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memberships" do
    field :role, Ecto.Enum, values: [:owner, :admin, :member], default: :member
    belongs_to :user, User
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(membership, attrs, user_scope) do
    membership
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> put_change(:user_id, user_scope.user.id)
    |> put_change(:organization_id, user_scope.organization.id)
  end
end
