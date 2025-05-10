defmodule ProofwithWeb.ApplicationLive.Organizations.Organization do
  @moduledoc false
  use ProofwithWeb, :live_view

  alias Proofwith.Organizations

  def mount(_params, _session, socket) do
    current_scope = socket.assigns.current_scope
    orgs = Organizations.list_organizations_with_projects(current_scope)

    {:ok, assign(socket, orgs: orgs, current_scope: current_scope)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <section class="mx-auto w-full max-w-screen-xl px-4">
        <div class="flex justify-between items-center px-4 my-8">
          <h1 class="text-2xl font-light">Your Organizations</h1>

          <.link navigate="/new" class="btn btn-sm btn-soft btn-accent border-accent/40">
            new organization
          </.link>
        </div>

        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <.link
            :for={%{org: org, projects: projects} <- @orgs}
            navigate={"/" <> org.slug <> "/projects"}
            class="no-underline"
          >
            <div class="card bg-base-200 border border-base-300 cursor-pointer p-3">
              <div class="flex items-center gap-3">
                <div class="rounded-full flex items-center justify-center">
                  <.icon name="hero-user-circle" class="size-5 shrink-0" />
                </div>
                <div>
                  <div class="font-semibold text-base">{org.name}</div>
                  <div class="text-xs text-base-content/60">@{org.slug}</div>
                  <div class="text-xs text-base-content/80 mt-1">
                    {length(projects)} project{if length(projects) == 1, do: "", else: "s"}
                  </div>
                </div>
              </div>
            </div>
          </.link>
        </div>

        <div :if={Enum.empty?(@orgs)} class="shadow-lg flex items-center justify-center">
          <span>You don't belong to any organizations yet.</span>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
