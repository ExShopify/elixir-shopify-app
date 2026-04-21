defmodule ShopifyApp.Shopify.Query.ShopDetails do
  use ShopifyAPI.GraphQL.GraphQLQuery
  use ShopifyApp.GraphQLLoader, dir: "../gql"

  @gql load_query_file("shop_details.graphql")

  def query_string, do: @gql

  # Root key in the GraphQL "data" response object.
  def name, do: "shop"

  # Return the whole shop object — no deeper path needed.
  def path, do: []
end
