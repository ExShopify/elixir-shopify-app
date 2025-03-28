defmodule ShopifyApp.ShopifyAPI.Initializer do
  @moduledoc false
  require Logger

  alias ShopifyApp.AuthTokens
  alias ShopifyApp.Shops
  alias ShopifyApp.UserTokens

  def app_init do
    [
      %ShopifyAPI.App{
        name: ShopifyApp.Config.app_name(),
        client_id: ShopifyApp.Config.api_key(),
        client_secret: ShopifyApp.Config.api_secret(),
        auth_redirect_uri: ShopifyApp.Config.auth_redirect_uri(),
        nonce: "test",
        scope: ShopifyApp.Config.app_scopes_string()
      }
    ]
  end

  def shop_init, do: Enum.map(Shops.all(), &Shops.to_shopify_api_struct/1)

  def shop_persist(%ShopifyAPI.AuthToken{shop_name: myshopify_domain}),
    do: ShopifyApp.Shops.insert(%{myshopify_domain: myshopify_domain})

  def shop_persist(_key, %ShopifyAPI.Shop{domain: myshopify_domain}),
    do: ShopifyApp.Shops.insert(%{myshopify_domain: myshopify_domain})

  def auth_token_init, do: Enum.map(AuthTokens.all(), &AuthTokens.to_shopify_api_struct/1)
  def auth_token_persist(_key, %ShopifyAPI.AuthToken{} = token), do: AuthTokens.upsert(token)

  def user_token_init, do: Enum.map(UserTokens.all(), &UserTokens.to_shopify_api_struct/1)
  def user_token_persist(_key, %ShopifyAPI.UserToken{} = token), do: UserTokens.upsert(token)
end
