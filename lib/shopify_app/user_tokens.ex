defmodule ShopifyApp.UserTokens do
  use ShopifyApp.Repo, define_types: ShopifyApp.Schema.UserToken.t()

  require Ecto.Query
  require Logger

  alias ShopifyApp.Repo
  alias ShopifyApp.Schema
  alias ShopifyApp.UserTokens.Query

  @transferable_shopify_api_attrs [
    :app_name,
    :associated_user_id,
    :associated_user_scope,
    :associated_user,
    :code,
    :expires_in,
    :plus,
    :scope,
    :timestamp,
    :token
  ]

  @spec all() :: list(t())
  @spec all(String.t()) :: list(t())
  def all(myshopify_domain),
    do: Query.from() |> Query.where_myshopify_domain(myshopify_domain) |> Repo.all()

  def all, do: Repo.all(Query.from())

  def upsert(%ShopifyAPI.UserToken{} = token) do
    token
    |> Map.take(@transferable_shopify_api_attrs)
    |> Map.put(:shop_myshopify_domain, token.shop_name)
    |> upsert()
  end

  def upsert(%{} = params) do
    %Schema.UserToken{}
    |> Schema.UserToken.changeset(params)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: [:associated_user_id])
  end

  def to_shopify_api_struct(%Schema.UserToken{} = token) do
    attrs =
      token
      |> Map.take(@transferable_shopify_api_attrs)
      |> Map.put(:shop_name, token.shop_myshopify_domain)

    struct(ShopifyAPI.UserToken, attrs)
  end
end
