defmodule ShopifyApp.Query.Shop do
  @moduledoc """
  A module for querying shops.
  """

  require Ecto.Query

  alias Ecto.Query

  alias ShopifyApp.Schema

  @type queryable() :: Ecto.Queryable.t()

  @spec from(Schema.Shop) :: Ecto.Queryable.t()
  def from(query \\ Schema.Shop)
  def from(Schema.Shop), do: Query.from(shop in Schema.Shop, as: :shop)

  @spec where_myshopify_domain(queryable(), String.t()) :: queryable()
  def where_myshopify_domain(query \\ from(), myshopify_domain),
    do: Query.where(query, [shop: s], s.myshopify_domain == ^myshopify_domain)
end
