defmodule ProofwithWeb.ApplicationLive.Organizations.New do
  @moduledoc false
  use ProofwithWeb, :live_view

  alias Proofwith.Organizations
  alias Proofwith.Organizations.Organization

  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    changeset = Organizations.change_organization(scope, %Organization{})
    form = to_form(changeset, as: "organization")
    {:ok, assign(socket, changeset: changeset, form: form, loading: false, scope: scope)}
  end

  def handle_event("validate", %{"organization" => org_params}, socket) do
    changeset =
      socket.assigns.scope
      |> Organizations.change_organization(%Organization{}, org_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset, as: "organization")
    {:noreply, assign(socket, changeset: changeset, form: form)}
  end

  def handle_event("save", %{"organization" => org_params}, socket) do
    case Organizations.create_organization(socket.assigns.scope, org_params) do
      {:ok, _org} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organization created successfully!")
         |> push_navigate(to: "/organizations")}

      {:error, %Ecto.Changeset{} = changeset} ->
        form = to_form(changeset, as: "organization")
        {:noreply, assign(socket, changeset: changeset, form: form, loading: false)}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@scope}>
      <div class="flex justify-center items-center min-h-screen bg-base-200">
        <div class="card w-full max-w-md shadow-xl bg-base-100">
          <div class="card-body">
            <h2 class="card-title">Create a new organization</h2>
            <.form for={@form} phx-submit="save" phx-change="validate" class="space-y-4">
              <.input field={@form[:name]} label="Name" class="input input-bordered w-full" />
              <.input field={@form[:slug]} label="Slug" class="input input-bordered w-full" />
              <div class="card-actions justify-end">
                <button class="btn btn-primary" type="submit" disabled={@loading}>
                  <%= if @loading do %>
                    Creating...
                  <% else %>
                    Create organization
                  <% end %>
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
