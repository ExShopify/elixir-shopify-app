defmodule ShopifyApp.Query.ShopSubscriptions do
  @moduledoc """
  A module for querying shop subscriptions.
  """
  require Ecto.Query

  alias Ecto.Query
  alias ShopifyApp.Model
  alias ShopifyApp.Schema

  @type queryable() :: Ecto.Queryable.t()

  @spec from(Schema.ShopSubscription) :: queryable()
  def from(query \\ Schema.ShopSubscription)

  def from(Schema.ShopSubscription),
    do: Query.from(ss in Schema.ShopSubscription, as: :shop_subscription)

  @spec where_myshopify_domain(queryable(), Model.Scope.t()) :: queryable()
  @spec where_myshopify_domain(queryable(), String.t()) :: queryable()
  def where_myshopify_domain(query \\ from(), scope_or_domain)

  def where_myshopify_domain(query, %Model.Scope{} = scope),
    do: where_myshopify_domain(query, Model.Scope.myshopify_domain(scope))

  def where_myshopify_domain(query, myshopify_domain) when is_binary(myshopify_domain),
    do: Query.where(query, [shop_subscription: ss], ss.shop_myshopify_domain == ^myshopify_domain)

  @spec where_id(queryable(), String.t()) :: queryable()
  def where_id(query \\ from(), id),
    do: Query.where(query, [shop_subscription: ss], ss.id == ^id)

  @spec where_shopify_id(queryable(), String.t()) :: queryable()
  def where_shopify_id(query \\ from(), subscription_id),
    do: Query.where(query, [shop_subscription: ss], ss.subscription_id == ^subscription_id)

  @spec where_status(queryable(), atom()) :: queryable()
  def where_status(query \\ from(), status),
    do: Query.where(query, [shop_subscription: ss], ss.status == ^status)

  @spec where_active(queryable()) :: queryable()
  def where_active(query \\ from()), do: where_status(query, :active)

  @spec where_subscription_id_not_in(queryable(), list(String.t())) :: queryable()
  def where_subscription_id_not_in(query \\ from(), subscription_ids),
    do: Query.where(query, [shop_subscription: ss], ss.subscription_id not in ^subscription_ids)
end
