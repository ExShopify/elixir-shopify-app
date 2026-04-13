defmodule ShopifyApp.Shopify.Shop do
  require Logger

  alias ShopifyAPI.GraphQL.GraphQLResponse
  alias ShopifyApp.Shopify.Query.ShopDetails

  @doc """
  Fetches the shop's details from the Shopify Admin API.

  Returns `{:ok, shop}` where `shop` is a map with the store's core fields,
  or `{:error, reason}` on failure.
  """
  @spec get_details(ShopifyAPI.Scope.t()) :: {:ok, map()} | {:error, term()}
  def get_details(scope) do
    ShopDetails.query()
    |> ShopDetails.execute(scope)
    |> GraphQLResponse.resolve()
    |> case do
      {:ok, shop} ->
        {:ok, shop}

      {:error, %GraphQLResponse{} = response} ->
        Logger.error("get_shop_details received errors: #{inspect(response.errors)}")
        {:error, :get_shop_details}

      {:error, error} ->
        Logger.error("get_shop_details received an unknown error: #{inspect(error)}")
        {:error, :get_shop_details}
    end
  end
end
