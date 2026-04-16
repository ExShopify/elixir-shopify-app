defmodule ShopifyAppWeb.ShopAdmin.DashboardLive.Index do
  use ShopifyAppWeb, :shop_admin_live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      page_title="ShopifApp"
    >
      <.text variant="headingLg">Welcome to your ShopifyApp dashboard!</.text>
    </Layouts.app>
    """
  end
end
