defmodule ShopifyApp.AuthTokens do
  @moduledoc false
  use ShopifyApp.Repo, define_types: ShopifyApp.Schema.AuthToken.t()

  alias ShopifyApp.Query
  alias ShopifyApp.Repo
  alias ShopifyApp.Schema

  def all, do: Repo.all(Schema.AuthToken)

  def insert(%{} = token) do
    token
    |> find_or_new()
    |> Schema.AuthToken.changeset(token)
    |> Repo.insert_or_update()
  end

  @spec find(String.t()) :: t() | nil
  def find(myshopify_domain), do: find(myshopify_domain, ShopifyApp.Config.app_handle())

  @spec find(String.t(), String.t()) :: t() | nil
  def find(myshopify_domain, app_handle) do
    Query.AuthToken.from()
    |> Query.AuthToken.where_myshopify_domain(myshopify_domain)
    |> Query.AuthToken.where_app_handle(app_handle)
    |> Repo.one()
  end

  def find_or_new(%{shop_myshopify_domain: myshopify_domain, app_handle: app_handle}) do
    case find(myshopify_domain, app_handle) do
      nil -> %Schema.AuthToken{shop_myshopify_domain: myshopify_domain, app_handle: app_handle}
      auth_token -> auth_token
    end
  end

  def upsert(%ShopifyAPI.AuthToken{} = token) do
    upsert(%{
      shop_myshopify_domain: token.myshopify_domain,
      app_handle: token.app_handle,
      token: token.token,
      plus: token.plus
    })
  end

  def upsert(%{} = params) do
    %Schema.AuthToken{}
    |> Schema.AuthToken.changeset(params)
    |> Repo.insert(
      on_conflict: {:replace, [:token, :plus]},
      conflict_target: [:shop_myshopify_domain, :app_handle]
    )
  end

  @spec to_shopify_api_struct(Schema.AuthToken.t()) :: ShopifyAPI.AuthToken.t()
  def to_shopify_api_struct(%Schema.AuthToken{} = token) do
    %ShopifyAPI.AuthToken{
      app_handle: token.app_handle,
      myshopify_domain: token.shop_myshopify_domain,
      token: token.token,
      timestamp: 0,
      plus: token.plus
    }
  end
end
