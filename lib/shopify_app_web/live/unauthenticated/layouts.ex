defmodule ShopifyAppWeb.Unauthenticated.Layouts do
  use ShopifyAppWeb, :html

  import OctantisWeb.Components.Polaris

  embed_templates "layouts/*"

  attr :flash, :map, required: true, doc: "the map of flash messages"

  slot :inner_block, required: true, doc: "the main content of the page"

  def app(assigns) do
    ~H"""
    <main role="main" id="root" data-phx-hook="ShopifyUserToken" phx-hook="ShopifyUserToken">
      <.s_query_container container_name="Page">
        <.s_page id="PageRoot">
          {render_slot(@inner_block)}
        </.s_page>
      </.s_query_container>
    </main>
    """
  end
end
