defmodule ProofwithWeb.ApplicationLive.Organizations.Organization do
  @moduledoc false
  use ProofwithWeb, :live_view

  def mount(socket) do
    current_scope = socket.assigns.current_scope

    socket = assign(socket, current_scope: current_scope)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1>Organizations</h1>
    </Layouts.app>
    """
  end
end
