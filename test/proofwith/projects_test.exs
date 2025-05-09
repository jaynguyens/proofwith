defmodule Proofwith.ProjectsTest do
  use Proofwith.DataCase

  alias Proofwith.Accounts.Scope
  alias Proofwith.Projects

  describe "projects" do
    import Proofwith.AccountsFixtures, only: [user_scope_fixture: 0]
    import Proofwith.OrganizationsFixtures, only: [organization_fixture: 1]
    import Proofwith.ProjectsFixtures

    alias Proofwith.Projects.Project

    @invalid_attrs %{meta: nil, name: nil, slug: nil}

    test "list_projects/1 returns all scoped projects" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      other_scope = user_scope_fixture()
      other_organization = organization_fixture(other_scope)
      other_scope = Scope.for_organization(other_scope, other_organization)
      project = project_fixture(scope)
      other_project = project_fixture(other_scope)
      assert Projects.list_projects(scope) == [project]
      assert Projects.list_projects(other_scope) == [other_project]
    end

    test "get_project!/2 returns the project with given id" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      project = project_fixture(scope)
      other_scope = user_scope_fixture()
      other_organization = organization_fixture(other_scope)
      other_scope = Scope.for_organization(other_scope, other_organization)
      assert Projects.get_project!(scope, project.id) == project
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(other_scope, project.id) end
    end

    test "create_project/2 with valid data creates a project" do
      valid_attrs = %{meta: %{}, name: "some name", slug: "some slug"}
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)

      assert {:ok, %Project{} = project} = Projects.create_project(scope, valid_attrs)
      assert project.meta == %{}
      assert project.name == "some name"
      assert project.slug == "some slug"
      # Project is now only scoped by organization, not user
    end

    test "create_project/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(scope, @invalid_attrs)
    end

    test "update_project/3 with valid data updates the project" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      project = project_fixture(scope)
      update_attrs = %{meta: %{}, name: "some updated name", slug: "some updated slug"}

      assert {:ok, %Project{} = project} = Projects.update_project(scope, project, update_attrs)
      assert project.meta == %{}
      assert project.name == "some updated name"
      assert project.slug == "some updated slug"
    end

    test "update_project/3 with invalid scope raises" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      other_scope = user_scope_fixture()
      other_organization = organization_fixture(other_scope)
      other_scope = Scope.for_organization(other_scope, other_organization)
      project = project_fixture(scope)

      assert_raise MatchError, fn ->
        Projects.update_project(other_scope, project, %{})
      end
    end

    test "update_project/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      project = project_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(scope, project, @invalid_attrs)
      assert project == Projects.get_project!(scope, project.id)
    end

    test "delete_project/2 deletes the project" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      project = project_fixture(scope)
      assert {:ok, %Project{}} = Projects.delete_project(scope, project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(scope, project.id) end
    end

    test "delete_project/2 with invalid scope raises" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      other_scope = user_scope_fixture()
      other_organization = organization_fixture(other_scope)
      other_scope = Scope.for_organization(other_scope, other_organization)
      project = project_fixture(scope)
      assert_raise MatchError, fn -> Projects.delete_project(other_scope, project) end
    end

    test "change_project/2 returns a project changeset" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      project = project_fixture(scope)
      assert %Ecto.Changeset{} = Projects.change_project(scope, project)
    end

    test "get_project_by_slug!/2 returns the project with given slug" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      project = project_fixture(scope)
      found = Projects.get_project_by_slug!(scope, project.slug)
      assert found.id == project.id
    end

    test "get_project_by_slug!/2 raises if slug does not exist for org" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      project_fixture(scope)

      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project_by_slug!(scope, "nonexistent-slug")
      end
    end

    test "get_project_by_slug!/2 does not return projects from other orgs" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      scope = Scope.for_organization(scope, organization)
      other_scope = user_scope_fixture()
      other_organization = organization_fixture(other_scope)
      other_scope = Scope.for_organization(other_scope, other_organization)
      project = project_fixture(other_scope)

      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project_by_slug!(scope, project.slug)
      end
    end
  end
end
