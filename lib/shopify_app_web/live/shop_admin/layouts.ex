defmodule ShopifyAppWeb.ShopAdminLive.Layouts do
  use ShopifyAppWeb, :html

  import OctantisWeb.Components.AppBridge
  import OctantisWeb.Components.Polaris

  embed_templates "layouts/*"

  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :page_title, :string, default: "ShopifyApp"
  attr :page_subtitle, :string, default: nil

  attr :page_primary_action, :map,
    default: %{},
    doc:
      "a map with keys :content, :patch or :navigate, and optional :id. This will be rendered as the primary action of the page header"

  attr :page_secondary_action, :list,
    default: [],
    doc:
      "a list of secondary action maps with keys :content, :patch or :navigate, and optional :id"

  slot :inner_block, required: true, doc: "the main content of the page"

  def app(assigns) do
    ~H"""
    <main role="main" id="root" data-phx-hook="ShopifyUserToken" phx-hook="ShopifyUserToken">
      <.toast kind={:info} flash={@flash} id="toastinfo" />
      <.toast kind={:error} flash={@flash} id="toasterror" />

      <.s_page title={@page_title} subtitle={@page_subtitle}>
        {render_slot(@inner_block)}
      </.s_page>
      <.box padding="400"><%!-- spacer --%></.box>
    </main>
    """
  end

  def link_paths(current_path, link_path) do
    path =
      if String.starts_with?(current_path, link_path) do
        current_path
      else
        link_path
      end

    %{url: path, navigate: link_path}
  end
end
