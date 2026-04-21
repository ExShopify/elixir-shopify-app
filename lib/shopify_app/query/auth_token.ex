defmodule ShopifyApp.Query.AuthToken do
  @moduledoc """
  A module for querying auth tokens.
  """

  require Ecto.Query

  alias Ecto.Query
  alias ShopifyApp.Model
  alias ShopifyApp.Schema

  @type queryable() :: Ecto.Queryable.t()

  @spec from(Schema.AuthToken) :: Ecto.Queryable.t()
  def from(query \\ Schema.AuthToken)
  def from(Schema.AuthToken), do: Query.from(auth_token in Schema.AuthToken, as: :auth_token)

  @spec where_myshopify_domain(queryable(), Model.Scope.t()) :: queryable()
  @spec where_myshopify_domain(queryable(), String.t()) :: queryable()
  def where_myshopify_domain(query \\ from(), scope_or_domain)

  def where_myshopify_domain(query, %Model.Scope{} = scope),
    do: where_myshopify_domain(query, Model.Scope.myshopify_domain(scope))

  def where_myshopify_domain(query, myshopify_domain) when is_binary(myshopify_domain),
    do: Query.where(query, [auth_token: at], at.shop_myshopify_domain == ^myshopify_domain)

  @spec where_app_handle(queryable(), String.t()) :: queryable()
  def where_app_handle(query \\ from(), app_handle) when is_binary(app_handle),
    do: Query.where(query, [auth_token: at], at.app_handle == ^app_handle)
end
