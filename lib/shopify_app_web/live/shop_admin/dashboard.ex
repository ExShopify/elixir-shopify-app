defmodule ShopifyAppWeb.ShopAdmin.DashboardLive do
  use ShopifyAppWeb, :shop_admin_live_view

  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
