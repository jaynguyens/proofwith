defmodule Proofwith.Projects.Project do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Proofwith.Organizations.Organization

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    field :slug, :string
    field :meta, :map
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(project, attrs, user_scope) do
    project
    |> cast(attrs, [:name, :slug, :meta])
    |> validate_required([:name, :slug])
    |> put_change(:organization_id, user_scope.organization.id)
  end
end
