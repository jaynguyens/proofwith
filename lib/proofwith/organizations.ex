defmodule Proofwith.Organizations do
  @moduledoc """
  The Organizations context.

  All functions require a `%Proofwith.Accounts.Scope{}` as the first argument,
  following the Phoenix 1.8 Scopes pattern.
  """

  import Ecto.Query, warn: false

  alias Proofwith.Accounts.Scope
  alias Proofwith.Organizations.Membership
  alias Proofwith.Organizations.Organization
  alias Proofwith.Repo

  @doc """
  Subscribes to scoped notifications about any organization changes.

  The broadcasted messages match the pattern:

    * {:created, %Organization{}}
    * {:updated, %Organization{}}
    * {:deleted, %Organization{}}

  """
  def subscribe_organizations(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Proofwith.PubSub, "user:#{key}:organizations")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Proofwith.PubSub, "user:#{key}:organizations", message)
  end

  @doc """
  Returns the list of organizations user is a member of.

  ## Examples

      iex> list_organizations(scope)
      [%Organization{}, ...]

  """
  def list_organizations(%Scope{} = scope) do
    Repo.all(
      from(o in Organization,
        left_join: m in Membership,
        on: m.organization_id == o.id and m.user_id == ^scope.user.id,
        where: o.user_id == ^scope.user.id or not is_nil(m.id),
        distinct: true
      )
    )
  end

  @doc """
  Returns the list of organizations with their projects.

  ## Examples

      iex> list_organizations_with_projects(scope)
      [%{org: %Organization{}, projects: [%Project{}, ...]}]
  """
  def list_organizations_with_projects(%Scope{} = scope) do
    orgs =
      scope
      |> list_organizations()
      |> Repo.preload(:projects)

    Enum.map(orgs, fn org ->
      %{org: org, projects: org.projects}
    end)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(scope, 123)
      %Organization{}

      iex> get_organization!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(%Scope{} = scope, id) do
    Repo.get_by!(Organization, id: id, user_id: scope.user.id)
  end

  @doc """
  Gets a single organization by slug for the current user scope.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization_by_slug!(scope, "org-slug")
      %Organization{}

      iex> get_organization_by_slug!(scope, "bad-slug")
      ** (Ecto.NoResultsError)

  """
  def get_organization_by_slug!(%Scope{} = scope, slug) when is_binary(slug) do
    Repo.get_by!(Organization, slug: slug, user_id: scope.user.id)
  end

  @doc """
  Creates an organization scoped to the current user.

  ## Examples

      iex> create_organization(scope, %{name: "Acme", slug: "acme"})
      {:ok, %Organization{}}

      iex> create_organization(scope, %{name: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(%Scope{} = scope, attrs) do
    %Organization{}
    |> Organization.changeset(attrs, scope)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(scope, organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(scope, organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Scope{} = scope, %Organization{} = organization, attrs) do
    true = organization.user_id == scope.user.id

    with {:ok, %Organization{} = organization} <-
           organization
           |> Organization.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, organization})
      {:ok, organization}
    end
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(scope, organization)
      {:ok, %Organization{}}

      iex> delete_organization(scope, organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Scope{} = scope, %Organization{} = organization) do
    true = organization.user_id == scope.user.id

    with {:ok, %Organization{} = organization} <-
           Repo.delete(organization) do
      broadcast(scope, {:deleted, organization})
      {:ok, organization}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(scope, %Organization{})
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Scope{} = scope, %Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs, scope)
  end

  @doc """
  Subscribes to scoped notifications about any membership changes.

  The broadcasted messages match the pattern:

    * {:created, %Membership{}}
    * {:updated, %Membership{}}
    * {:deleted, %Membership{}}

  """
  def subscribe_memberships(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Proofwith.PubSub, "user:#{key}:memberships")
  end

  @doc """
  Returns the list of memberships.

  ## Examples

      iex> list_memberships(scope)
      [%Membership{}, ...]

  """
  def list_memberships(%Scope{} = scope) do
    Repo.all(from membership in Membership, where: membership.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single membership.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(scope, 123)
      %Membership{}

      iex> get_membership!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_membership!(%Scope{} = scope, id) do
    Repo.get_by!(Membership, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a membership.

  ## Examples

      iex> create_membership(scope, %{field: value})
      {:ok, %Membership{}}

      iex> create_membership(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(%Scope{} = scope, attrs) do
    with {:ok, %Membership{} = membership} <-
           %Membership{}
           |> Membership.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, membership})
      {:ok, membership}
    end
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(scope, membership, %{field: new_value})
      {:ok, %Membership{}}

      iex> update_membership(scope, membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Scope{} = scope, %Membership{} = membership, attrs) do
    true = membership.user_id == scope.user.id

    with {:ok, %Membership{} = membership} <-
           membership
           |> Membership.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, membership})
      {:ok, membership}
    end
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(scope, membership)
      {:ok, %Membership{}}

      iex> delete_membership(scope, membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Scope{} = scope, %Membership{} = membership) do
    true = membership.user_id == scope.user.id

    with {:ok, %Membership{} = membership} <-
           Repo.delete(membership) do
      broadcast(scope, {:deleted, membership})
      {:ok, membership}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(scope, membership)
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Scope{} = scope, %Membership{} = membership, attrs \\ %{}) do
    true = membership.user_id == scope.user.id

    Membership.changeset(membership, attrs, scope)
  end
end
