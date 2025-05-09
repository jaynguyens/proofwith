defmodule Proofwith.OrganizationsTest do
  use Proofwith.DataCase

  alias Proofwith.Organizations

  describe "organizations" do
    import Proofwith.AccountsFixtures, only: [user_scope_fixture: 0]
    import Proofwith.OrganizationsFixtures

    alias Proofwith.Organizations.Organization

    @invalid_attrs %{meta: nil, name: nil, slug: nil}

    test "list_organizations/1 returns all scoped organizations" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(scope)
      other_organization = organization_fixture(other_scope)
      assert Organizations.list_organizations(scope) == [organization]
      assert Organizations.list_organizations(other_scope) == [other_organization]
    end

    test "get_organization!/2 returns the organization with given id" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      other_scope = user_scope_fixture()
      assert Organizations.get_organization!(scope, organization.id) == organization
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(other_scope, organization.id) end
    end

    test "create_organization/2 with valid data creates a organization" do
      valid_attrs = %{meta: %{}, name: "some name", slug: "some slug"}
      scope = user_scope_fixture()

      assert {:ok, %Organization{} = organization} = Organizations.create_organization(scope, valid_attrs)
      assert organization.meta == %{}
      assert organization.name == "some name"
      assert organization.slug == "some slug"
      assert organization.user_id == scope.user.id
    end

    test "create_organization/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(scope, @invalid_attrs)
    end

    test "update_organization/3 with valid data updates the organization" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      update_attrs = %{meta: %{}, name: "some updated name", slug: "some updated slug"}

      assert {:ok, %Organization{} = organization} = Organizations.update_organization(scope, organization, update_attrs)
      assert organization.meta == %{}
      assert organization.name == "some updated name"
      assert organization.slug == "some updated slug"
    end

    test "update_organization/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(scope)

      assert_raise MatchError, fn ->
        Organizations.update_organization(other_scope, organization, %{})
      end
    end

    test "update_organization/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Organizations.update_organization(scope, organization, @invalid_attrs)
      assert organization == Organizations.get_organization!(scope, organization.id)
    end

    test "delete_organization/2 deletes the organization" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      assert {:ok, %Organization{}} = Organizations.delete_organization(scope, organization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(scope, organization.id) end
    end

    test "delete_organization/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(scope)
      assert_raise MatchError, fn -> Organizations.delete_organization(other_scope, organization) end
    end

    test "change_organization/2 returns a organization changeset" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      assert %Ecto.Changeset{} = Organizations.change_organization(scope, organization)
    end

    test "get_organization_by_slug!/2 returns the organization with given slug" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      found = Organizations.get_organization_by_slug!(scope, organization.slug)
      assert found.id == organization.id
    end

    test "get_organization_by_slug!/2 raises if slug does not exist for user" do
      scope = user_scope_fixture()
      organization_fixture(scope)

      assert_raise Ecto.NoResultsError, fn ->
        Organizations.get_organization_by_slug!(scope, "nonexistent-slug")
      end
    end

    test "get_organization_by_slug!/2 does not return orgs from other users" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      organization = organization_fixture(other_scope)

      assert_raise Ecto.NoResultsError, fn ->
        Organizations.get_organization_by_slug!(scope, organization.slug)
      end
    end
  end

  describe "memberships" do
    import Proofwith.AccountsFixtures, only: [user_scope_fixture: 0]
    import Proofwith.OrganizationsFixtures

    alias Proofwith.Organizations.Membership

    @invalid_attrs %{role: nil}

    test "list_memberships/1 returns all scoped memberships" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership = membership_fixture(scope)
      other_membership = membership_fixture(other_scope)
      assert Organizations.list_memberships(scope) == [membership]
      assert Organizations.list_memberships(other_scope) == [other_membership]
    end

    test "get_membership!/2 returns the membership with given id" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      other_scope = user_scope_fixture()
      assert Organizations.get_membership!(scope, membership.id) == membership
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_membership!(other_scope, membership.id) end
    end

    test "create_membership/2 with valid data creates a membership" do
      valid_attrs = %{role: :member}
      scope = user_scope_fixture()

      assert {:ok, %Membership{} = membership} = Organizations.create_membership(scope, valid_attrs)
      assert membership.role == :member
      assert membership.user_id == scope.user.id
    end

    test "create_membership/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.create_membership(scope, @invalid_attrs)
    end

    test "update_membership/3 with valid data updates the membership" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      update_attrs = %{role: :admin}

      assert {:ok, %Membership{} = membership} = Organizations.update_membership(scope, membership, update_attrs)
      assert membership.role == :admin
    end

    test "update_membership/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership = membership_fixture(scope)

      assert_raise MatchError, fn ->
        Organizations.update_membership(other_scope, membership, %{})
      end
    end

    test "update_membership/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Organizations.update_membership(scope, membership, @invalid_attrs)
      assert membership == Organizations.get_membership!(scope, membership.id)
    end

    test "delete_membership/2 deletes the membership" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert {:ok, %Membership{}} = Organizations.delete_membership(scope, membership)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_membership!(scope, membership.id) end
    end

    test "delete_membership/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert_raise MatchError, fn -> Organizations.delete_membership(other_scope, membership) end
    end

    test "change_membership/2 returns a membership changeset" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert %Ecto.Changeset{} = Organizations.change_membership(scope, membership)
    end
  end
end
