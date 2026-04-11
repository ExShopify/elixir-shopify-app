defmodule ShopifyAppWeb.ShopAdminLive.Layouts do
  use ShopifyAppWeb, :html

  import OctantisWeb.Components.AppBridge
  import OctantisWeb.Components.Polaris

  embed_templates "layouts/*"

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
