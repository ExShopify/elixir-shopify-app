defmodule ShopifyApp.Shopify.Subscription do
  @moduledoc """
  Fetches and processes Shopify app subscriptions for a shop.
  """
  require Logger

  alias ShopifyAPI.GraphQL.GraphQLResponse
  alias ShopifyApp.Shopify.Query.CurrentAppInstallation

  @doc """
  Fetches the current active subscriptions from Shopify's currentAppInstallation query.

  Returns `{:ok, subscriptions}` where `subscriptions` is a list of subscription maps,
  or `{:error, reason}` on failure.
  """
  @spec fetch_current_subscriptions(ShopifyAPI.Scope.t()) :: {:ok, list(map())} | {:error, term()}
  def fetch_current_subscriptions(scope) do
    CurrentAppInstallation.query()
    |> CurrentAppInstallation.execute(scope)
    |> GraphQLResponse.resolve()
    |> case do
      {:ok, %{"activeSubscriptions" => %{"edges" => edges}}} ->
        subscriptions = Enum.map(edges, & &1["node"])
        {:ok, subscriptions}

      {:ok, _installation} ->
        # No active subscriptions
        {:ok, []}

      {:error, %GraphQLResponse{} = response} ->
        Logger.error("fetch_current_subscriptions received errors: #{inspect(response.errors)}")
        {:error, :fetch_current_subscriptions}

      {:error, error} ->
        Logger.error("fetch_current_subscriptions received an unknown error: #{inspect(error)}")
        {:error, :fetch_current_subscriptions}
    end
  end
end
