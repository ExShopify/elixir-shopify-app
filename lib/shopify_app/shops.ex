defmodule ShopifyApp.Shops do
  @moduledoc false
  use ShopifyApp.Repo, define_types: ShopifyApp.Schema.Shop.t()

  alias ShopifyApp.Query
  alias ShopifyApp.Repo
  alias ShopifyApp.Schema

  def all, do: Repo.all(Schema.Shop)

  @spec insert(map()) :: ok_changeset_error()
  def insert(%{} = shop),
    do: shop |> find_or_new() |> Schema.Shop.changeset(shop) |> Repo.insert_or_update()

  @spec find(String.t()) :: t() | nil
  def find(myshopify_domain) when is_binary(myshopify_domain),
    do: Query.Shop.from() |> Query.Shop.where_myshopify_domain(myshopify_domain) |> Repo.one()

  @spec fetch(String.t()) :: ok_error_not_found()
  def fetch(myshopify_domain), do: myshopify_domain |> find() |> Repo.ok_or_not_found()

  @spec find_or_new(map()) :: t()
  def find_or_new(%{myshopify_domain: myshopify_domain}) do
    case find(myshopify_domain) do
      nil -> %Schema.Shop{}
      shop -> shop
    end
  end

  @spec delete(t()) :: ok_changeset_error()
  def delete(%Schema.Shop{} = shop), do: Repo.delete(shop)

  @spec update(t(), map()) :: ok_changeset_error()
  def update(%Schema.Shop{} = shop, attrs),
    do: shop |> Schema.Shop.changeset(attrs) |> Repo.update()

  def to_shopify_api_struct(%Schema.Shop{myshopify_domain: myshopify_domain}),
    do: %ShopifyAPI.Shop{myshopify_domain: myshopify_domain}
end
