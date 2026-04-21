defmodule ShopifyApp.Query.UserToken do
  @moduledoc """
  A module for querying user tokens.
  """

  require Ecto.Query

  alias Ecto.Query
  alias ShopifyApp.Model
  alias ShopifyApp.Schema

  @type queryable() :: Ecto.Queryable.t()

  @spec from(Schema.UserToken) :: Ecto.Queryable.t()
  def from(query \\ Schema.UserToken)
  def from(Schema.UserToken), do: Query.from(u in Schema.UserToken, as: :user_token)

  @spec where_myshopify_domain(queryable(), Model.Scope.t()) :: queryable()
  @spec where_myshopify_domain(queryable(), String.t()) :: queryable()
  def where_myshopify_domain(query \\ from(), scope_or_domain)

  def where_myshopify_domain(query, %Model.Scope{} = scope),
    do: where_myshopify_domain(query, Model.Scope.myshopify_domain(scope))

  def where_myshopify_domain(query, myshopify_domain) when is_binary(myshopify_domain),
    do: Query.where(query, [user_token: ut], ut.shop_myshopify_domain == ^myshopify_domain)
end
