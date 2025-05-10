defmodule Proofwith.OrganizationsTest do
  use Proofwith.DataCase

  alias Proofwith.Accounts.Scope
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

    test "list_organizations/1 returns orgs user owns or is a member of (ownership and membership)" do
      owner1_scope = user_scope_fixture()
      owner2_scope = user_scope_fixture()
      member_scope = user_scope_fixture()
      org1 = organization_fixture(owner1_scope)
      org2 = organization_fixture(owner2_scope)

      member_scope_org1 = Scope.for_organization(member_scope, org1)
      member_scope_org2 = Scope.for_organization(member_scope, org2)

      {:ok, _m1} = Proofwith.Organizations.create_membership(member_scope_org1, %{role: :member})
      {:ok, _m2} = Proofwith.Organizations.create_membership(member_scope_org2, %{role: :member})

      orgs = Organizations.list_organizations(member_scope)
      org_ids = Enum.map(orgs, & &1.id)

      assert org1.id in org_ids
      assert org2.id in org_ids
    end

    test "list_organizations_with_projects/1 returns orgs with preloaded projects" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      if is_nil(org), do: raise("organization_fixture returned nil")
      org_scope = Scope.for_organization(scope, org)
      # Insert projects for this org with unique slugs
      project1 = Proofwith.ProjectsFixtures.project_fixture(org_scope, %{slug: "slug-1"})
      project2 = Proofwith.ProjectsFixtures.project_fixture(org_scope, %{slug: "slug-2"})

      result = Organizations.list_organizations_with_projects(scope)
      org_entry = Enum.find(result, fn %{org: o} -> o.id == org.id end)

      assert org_entry
      project_ids = Enum.map(org_entry.projects, & &1.id)
      assert project1.id in project_ids
      assert project2.id in project_ids
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
      org1 = organization_fixture(scope)
      org2 = organization_fixture(other_scope)
      scope1 = Scope.for_organization(scope, org1)
      scope2 = Scope.for_organization(other_scope, org2)
      membership = membership_fixture(scope1)
      other_membership = membership_fixture(scope2)
      assert Organizations.list_memberships(scope1) == [membership]
      assert Organizations.list_memberships(scope2) == [other_membership]
    end

    test "get_membership!/2 returns the membership with given id" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      membership = membership_fixture(scope)
      other_scope = user_scope_fixture()
      other_org = organization_fixture(other_scope)
      other_scope = Scope.for_organization(other_scope, other_org)
      assert Organizations.get_membership!(scope, membership.id) == membership
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_membership!(other_scope, membership.id) end
    end

    test "create_membership/2 with valid data creates a membership" do
      valid_attrs = %{role: :member}
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      assert {:ok, %Membership{} = membership} = Organizations.create_membership(scope, valid_attrs)
      assert membership.role == :member
      assert membership.user_id == scope.user.id
    end

    test "create_membership/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      assert {:error, %Ecto.Changeset{}} = Organizations.create_membership(scope, @invalid_attrs)
    end

    test "update_membership/3 with valid data updates the membership" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      membership = membership_fixture(scope)
      update_attrs = %{role: :admin}
      assert {:ok, %Membership{} = membership} = Organizations.update_membership(scope, membership, update_attrs)
      assert membership.role == :admin
    end

    test "update_membership/3 with invalid scope raises" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      other_scope = user_scope_fixture()
      other_org = organization_fixture(other_scope)
      other_scope = Scope.for_organization(other_scope, other_org)
      membership = membership_fixture(scope)

      assert_raise MatchError, fn ->
        Organizations.update_membership(other_scope, membership, %{})
      end
    end

    test "update_membership/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      membership = membership_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Organizations.update_membership(scope, membership, @invalid_attrs)
      assert membership == Organizations.get_membership!(scope, membership.id)
    end

    test "delete_membership/2 deletes the membership" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      membership = membership_fixture(scope)
      assert {:ok, %Membership{}} = Organizations.delete_membership(scope, membership)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_membership!(scope, membership.id) end
    end

    test "delete_membership/2 with invalid scope raises" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      other_scope = user_scope_fixture()
      other_org = organization_fixture(other_scope)
      other_scope = Scope.for_organization(other_scope, other_org)
      membership = membership_fixture(scope)
      assert_raise MatchError, fn -> Organizations.delete_membership(other_scope, membership) end
    end

    test "change_membership/2 returns a membership changeset" do
      scope = user_scope_fixture()
      org = organization_fixture(scope)
      scope = Scope.for_organization(scope, org)
      membership = membership_fixture(scope)
      assert %Ecto.Changeset{} = Organizations.change_membership(scope, membership)
    end
  end
end
