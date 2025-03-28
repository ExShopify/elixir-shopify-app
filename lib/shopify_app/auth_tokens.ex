defmodule ShopifyApp.AuthTokens do
  @moduledoc false
  alias ShopifyApp.Repo
  alias ShopifyApp.Schema

  def all, do: Repo.all(Schema.AuthToken)

  def insert(token) do
    token
    |> find_or_new()
    |> Schema.AuthToken.changeset(token)
    |> Repo.insert_or_update()
  end

  def find_or_new(%{shop_myshopify_domain: shop_myshopify_domain, app_name: app_name}) do
    case Repo.get_by(Schema.AuthToken,
           shop_myshopify_domain: shop_myshopify_domain,
           app_name: app_name
         ) do
      nil -> %Schema.AuthToken{}
      auth_token -> auth_token
    end
  end

  def upsert(%ShopifyAPI.AuthToken{} = token) do
    upsert(%{
      shop_myshopify_domain: token.shop_name,
      app_name: token.app_name,
      token: token.token,
      plus: token.plus
    })
  end

  def upsert(%{} = params) do
    %Schema.AuthToken{}
    |> Schema.AuthToken.changeset(params)
    |> Repo.insert(
      on_conflict: {:replace, [:token, :plus]},
      conflict_target: :shop_name
    )
  end

  def to_shopify_api_struct(%Schema.AuthToken{} = token) do
    %ShopifyAPI.AuthToken{
      app_name: token.app_name,
      shop_name: token.shop_myshopify_domain,
      token: token.token,
      timestamp: 0,
      plus: token.plus
    }
  end
end
