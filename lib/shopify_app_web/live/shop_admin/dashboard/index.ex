defmodule ShopifyAppWeb.ShopAdmin.DashboardLive.Index do
  use ShopifyAppWeb, :shop_admin_live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
