defmodule Proofwith.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Proofwith.Organizations` context.
  """

  @doc """
  Generate a unique organization slug.
  """
  def unique_organization_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a organization.
  """
  def organization_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        meta: %{},
        name: "some name",
        slug: unique_organization_slug()
      })

    {:ok, organization} = Proofwith.Organizations.create_organization(scope, attrs)
    organization
  end

  @doc """
  Generate a membership.
  """
  def membership_fixture(scope, attrs \\ %{}) do
    org = Map.get(attrs, :organization) || organization_fixture(scope)
    scope = Proofwith.Accounts.Scope.for_organization(scope, org)
    attrs = Map.put_new(attrs, :role, :owner)
    {:ok, membership} = Proofwith.Organizations.create_membership(scope, attrs)
    membership
  end
end
