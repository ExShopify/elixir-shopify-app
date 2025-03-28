defmodule ShopifyApp.Config do
  @shopify_config_file :shopify_app
                       |> Application.compile_env(__MODULE__)
                       |> Keyword.get(:shopify_config_file)
  @shopify_config Toml.decode_file!(@shopify_config_file)
  @app_scopes_string get_in(@shopify_config, ["access_scopes", "scopes"]) ||
                       raise("failed to parse app toml and fetch scopes")

  @shop_webhooks ~w/APP_UNINSTALLED SHOP_UPDATE/

  def app_name, do: "shopify_app"
  def app_scopes_string, do: @app_scopes_string

  def api_key, do: shopify_config(:api_key)
  def api_secret, do: shopify_config(:api_secret)
  def auth_redirect_uri, do: shopify_config(:auth_redirect_uri)
  def admin_api_endpoint, do: shopify_config(:admin_api_endpoint)

  @spec shop_webhooks() :: list(String.t())
  def shop_webhooks, do: @shop_webhooks

  defp shopify_config(key), do: :shopify_app |> Application.get_env(:shopify) |> Keyword.get(key)
end
