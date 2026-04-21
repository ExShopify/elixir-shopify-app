defmodule ShopifyAppWeb.ShopAdmin.Hooks.AssignLayoutDefaults do
  @moduledoc """
  Assigns defaults required for the ShopAdminLive layout.

  These layouts can be overriden in the LiveView's apply_action/3 function.
  """

  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> assign_new(:processing, fn -> nil end)
      |> assign_new(:locked, fn -> nil end)
      |> assign_new(:page_title, fn -> nil end)
      |> assign_new(:page_title_badge, fn -> nil end)
      |> assign_new(:page_heading, fn -> nil end)
      |> assign_new(:page_breadcrumb_actions, fn -> [] end)
      |> assign_new(:page_subtitle, fn -> nil end)
      |> assign_new(:page_full_width, fn -> false end)
      |> assign_new(:page_title_metadata, fn -> nil end)
      |> assign_new(:page_back_action, fn -> [] end)
      |> assign_new(:page_primary_action, fn -> [] end)
      |> assign_new(:page_secondary_action, fn -> [] end)
      |> assign_new(:page_footer, fn -> nil end)
      |> assign_new(:page_nav_current_path, fn -> "" end)

    {:cont, socket}
  end
end
