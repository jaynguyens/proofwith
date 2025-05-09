defmodule ProofwithWeb.Scopes do
  @moduledoc """
  A scope for an organization.
  """

  alias Proofwith.Accounts.Scope
  alias Proofwith.Organizations
  alias Proofwith.Projects

  # For org scope
  def on_mount(:require_org_scope, %{"org_slug" => slug}, _session, socket) do
    current_scope = socket.assigns.current_scope

    try do
      org = Organizations.get_organization_by_slug!(current_scope, slug)
      scope = Scope.for_organization(current_scope, org)
      {:cont, Phoenix.Component.assign(socket, :current_scope, scope)}
    rescue
      Ecto.NoResultsError ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/")}
    end
  end

  def on_mount(:require_project_scope, %{"project_slug" => slug}, _session, socket) do
    current_scope = socket.assigns.current_scope

    try do
      project = Projects.get_project_by_slug!(current_scope, slug)
      scope = Scope.for_project(current_scope, project)
      {:cont, Phoenix.Component.assign(socket, :current_scope, scope)}
    rescue
      Ecto.NoResultsError ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/")}
    end
  end
end
