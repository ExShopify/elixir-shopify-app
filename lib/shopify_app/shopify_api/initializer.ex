defmodule ShopifyApp.ShopifyAPI.Initializer do
  @moduledoc false
  alias ShopifyApp.AuthTokens
  alias ShopifyApp.Shops
  alias ShopifyApp.UserTokens

  def app_init do
    ShopifyApp.Config.shopify_toml_config()
    |> ShopifyAPI.App.new()
    |> ShopifyAPI.App.with_client_secret(ShopifyApp.Config.api_secret())
    |> Map.merge(%{nonce: "test"})
    |> List.wrap()
  end

  def shop_init, do: Enum.map(Shops.all(), &Shops.to_shopify_api_struct/1)

  def shop_persist(%ShopifyAPI.AuthToken{myshopify_domain: myshopify_domain}),
    do: ShopifyApp.Shops.insert(%{myshopify_domain: myshopify_domain})

  def shop_persist(_key, %ShopifyAPI.Shop{myshopify_domain: myshopify_domain}),
    do: ShopifyApp.Shops.insert(%{myshopify_domain: myshopify_domain})

  def auth_token_init, do: Enum.map(AuthTokens.all(), &AuthTokens.to_shopify_api_struct/1)
  def auth_token_persist(_key, %ShopifyAPI.AuthToken{} = token), do: AuthTokens.upsert(token)

  def user_token_init, do: Enum.map(UserTokens.all(), &UserTokens.to_shopify_api_struct/1)
  def user_token_persist(_key, %ShopifyAPI.UserToken{} = token), do: UserTokens.upsert(token)
end
