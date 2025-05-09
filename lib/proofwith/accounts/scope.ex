defmodule Proofwith.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `Proofwith.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be access for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias Proofwith.Accounts.User
  alias Proofwith.Organizations.Organization
  alias Proofwith.Projects.Project

  defstruct user: nil, organization: nil, project: nil

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  def for_user(%User{} = user) do
    %__MODULE__{user: user}
  end

  def for_user(nil), do: nil

  @doc """
  Creates a scope for the given organization.

  Returns the scope if no organization is given.
  """
  def for_organization(scope, %Organization{} = organization) do
    %{scope | organization: organization}
  end

  def for_organization(scope, nil), do: scope

  @doc """
  Creates a scope for the given project.

  Returns the scope if no project is given.
  """
  def for_project(scope, %Project{} = project) do
    %{scope | project: project}
  end

  def for_project(scope, nil), do: scope
end
