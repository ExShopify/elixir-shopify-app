defmodule ShopifyApp.Config do
  @shopify_config_file :shopify_app
                       |> Application.compile_env(__MODULE__)
                       |> Keyword.get(:shopify_config_file)
  @shopify_config Toml.decode_file!(@shopify_config_file)
  @app_scopes_string get_in(@shopify_config, ["access_scopes", "scopes"]) ||
                       raise("failed to parse app toml and fetch scopes")

  @webhook_config get_in(@shopify_config, ["webhooks", "subscriptions"]) ||
                    raise("failed to parse app toml and fetch webhooks")
  @shop_webhook_topics @webhook_config |> List.first() |> get_in(["topics"]) || []
  @shop_webhook_compliance @webhook_config |> List.first() |> get_in(["compliance_topics"]) || []
  @shop_webhooks @shop_webhook_topics ++ @shop_webhook_compliance

  def shopify_toml_config, do: @shopify_config

  def app_name, do: @shopify_config["name"]
  def app_handle, do: @shopify_config["handle"]
  def app_scopes_string, do: @app_scopes_string

  def api_key, do: shopify_config(:api_key)
  def api_secret, do: shopify_config(:api_secret)
  def auth_redirect_uri, do: shopify_config(:auth_redirect_uri)
  def admin_api_endpoint, do: shopify_config(:admin_api_endpoint)

  @spec shop_webhooks() :: list(String.t())
  def shop_webhooks, do: @shop_webhooks

  defp shopify_config(key), do: :shopify_app |> Application.get_env(:shopify) |> Keyword.get(key)
end
