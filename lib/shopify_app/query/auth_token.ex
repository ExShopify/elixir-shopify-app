defmodule ShopifyApp.Query.AuthToken do
  @moduledoc """
  A module for querying auth tokens.
  """

  require Ecto.Query

  alias Ecto.Query

  alias ShopifyApp.Schema

  @type queryable() :: Ecto.Queryable.t()

  @spec from(Schema.AuthToken) :: Ecto.Queryable.t()
  def from(query \\ Schema.AuthToken)
  def from(Schema.AuthToken), do: Query.from(auth_token in Schema.AuthToken, as: :auth_token)

  @spec where_myshopify_domain(queryable(), String.t()) :: queryable()
  def where_myshopify_domain(query \\ from(), myshopify_domain),
    do: Query.where(query, [auth_token: at], at.shop_myshopify_domain == ^myshopify_domain)

  @spec where_app_name(queryable(), String.t()) :: queryable()
  def where_app_name(query \\ from(), app_name),
    do: Query.where(query, [auth_token: at], at.app_name == ^app_name)
end
