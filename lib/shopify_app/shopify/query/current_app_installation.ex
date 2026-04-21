defmodule ShopifyApp.Shopify.Query.CurrentAppInstallation do
  @moduledoc false
  use ShopifyAPI.GraphQL.GraphQLQuery
  use ShopifyApp.GraphQLLoader, dir: "../gql"

  @gql load_query_file("current_app_installation.graphql")

  def query_string, do: @gql

  def name, do: "currentAppInstallation"

  def path, do: []
end
