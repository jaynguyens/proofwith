defmodule Proofwith.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Proofwith.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        meta: %{},
        name: "some name",
        slug: "some slug"
      })

    {:ok, project} = Proofwith.Projects.create_project(scope, attrs)
    project
  end
end
