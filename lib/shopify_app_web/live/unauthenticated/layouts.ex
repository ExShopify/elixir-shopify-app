defmodule ShopifyAppWeb.Unauthenticated.Layouts do
  use ShopifyAppWeb, :html

  import OctantisWeb.Components.Polaris

  embed_templates "layouts/*"
end
