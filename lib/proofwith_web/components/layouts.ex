defmodule ProofwithWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use ProofwithWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="px-4 py-2 w-full flex justify-between items-center border-b border-base-300">
      <div class="flex items-center justify-between h-full pr-3 flex-1 overflow-x-auto gap-x-8 pl-4">
        <div class="flex items-center text-sm">
          <a href="/" class="flex items-center gap-2">
            <img src={~p"/images/logo.svg"} width="26" height="18" />
          </a>
          <span class="mx-4 text-base-300">/</span>
          <%!-- <nav :if={@breadcrumb != []} aria-label="Breadcrumb">
              <ol class="flex items-center space-x-2 text-sm text-base-content">
                <%= for {{label, path}, idx} <- Enum.with_index(@breadcrumb) do %>
                  <li class="flex items-center">
                    <a href={path}>{label}</a>
                    <span :if={idx < length(@breadcrumb) - 1} class="mx-2 text-base-300">/</span>
                  </li>
                <% end %>
              </ol>
            </nav> --%>
        </div>
        <div class="flex items-center gap-x-2">
          <button class="btn btn-outline btn-sm border-base-300">Feedback</button>
          <button class="btn btn-ghost btn-sm btn-square">
            <.icon name="hero-question-mark-circle" class="size-4 shrink-0" />
          </button>
          <.theme_toggle />
        </div>
      </div>
    </header>

    <main class="flex-1">
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  @doc """
  Renders an organization layout with a sidebar and main content area.
  Intended to be nested inside <Layouts.app> (no header/flash).

  ## Assigns
  - :active_page - the key of the current page (for sidebar highlighting)
  - :org - the organization struct (for sidebar links)

  ## Example
    <Layouts.app ...>
      <Layouts.org org={@org} active_page={:team}>
        ...
      </Layouts.org>
    </Layouts.app>
  """
  attr :active_page, :atom, required: true
  attr :org, :map, required: true
  slot :inner_block, required: true

  def org(assigns) do
    sidebar_items = [
      %{
        key: :projects,
        label: "Projects",
        path: "/#{assigns.org.slug}/projects",
        icon: "hero-folder"
      },
      %{key: :team, label: "Team", path: "/#{assigns.org.slug}/team", icon: "hero-users"},
      %{
        key: :billing,
        label: "Billing",
        path: "/#{assigns.org.slug}/billing",
        icon: "hero-credit-card"
      },
      %{
        key: :settings,
        label: "Settings",
        path: "/#{assigns.org.slug}/settings",
        icon: "hero-cog-6-tooth"
      }
    ]

    assigns = assign(assigns, sidebar_items: sidebar_items)

    ~H"""
    <section class="w-full h-[calc(100dvh-48px)] flex">
      <aside class="hidden md:block w-64 h-full border-r border-base-300">
        <ul class="menu bg-base-200 p-4 w-full h-full shadow-md space-y-1">
          <%= for item <- @sidebar_items do %>
            <.link
              navigate={item.path}
              class={[
                "flex items-center gap-2 px-3 py-2 rounded-lg transition",
                @active_page == item.key && "bg-base-300 text-base-content",
                @active_page != item.key && "hover:bg-base-300"
              ]}
            >
              <.icon name={item.icon} class="size-5" />
              {item.label}
            </.link>
          <% end %>
        </ul>
      </aside>

      <div class="flex-1">
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end
end
