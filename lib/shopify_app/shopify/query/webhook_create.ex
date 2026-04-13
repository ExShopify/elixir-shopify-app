defmodule ShopifyApp.Shopify.Query.WebhookCreate do
  use ShopifyAPI.GraphQL.GraphQLQuery
  use ShopifyApp.GraphQLLoader, dir: "../gql"
  require Logger

  alias ShopifyAPI.GraphQL.GraphQLResponse

  @gql load_query_file("webhook_create.graphql")

  def query_string, do: @gql
  def name, do: "webhookSubscriptionCreate"
  def path, do: ["webhookSubscription"]

  @type response() :: {:ok, map() | :already_created} | {:error, :create_webhook}

  @error_addr_already_taken "Address for this topic has already been taken"

  @spec create(ShopifyAPI.Scope.t(), String.t()) :: response()
  def create(scope, topic) do
    callback_url = ShopifyAppWeb.Router.webhooks_url()

    query()
    |> assigns(%{topic: topic, callback_url: callback_url})
    |> execute(scope)
    |> GraphQLResponse.resolve()
    |> case do
      {:ok, webhook} ->
        {:ok, webhook}

      {:error, %GraphQLResponse{user_errors: [%{"message" => @error_addr_already_taken} | _]}} ->
        {:ok, :already_created}

      {:error, %GraphQLResponse{} = response} ->
        Logger.error("create webhook received user errors: #{inspect(response.user_errors)}")
        {:error, :create_webhook}

      {:error, error} ->
        Logger.error("create webhook received an unknown error: #{inspect(error)}")
        {:error, :create_webhook}
    end
  end
end
