defmodule ShopifyApp.Worker.ShopSubscription.Sync do
  @moduledoc """
  Async worker that syncs shop subscriptions from Shopify to the database.
  Enqueued by the webhook handler and app install workflow.
  """
  use Oban.Worker

  alias ShopifyApp.Model
  alias ShopifyApp.Workflow

  @impl Oban.Worker
  def perform(%_{args: %{"myshopify_domain" => myshopify_domain}}) do
    with {:ok, scope} <- Model.Scope.new(myshopify_domain) do
      [scope: scope]
      |> Workflow.SyncShopSubscriptions.new()
      |> Workflow.SyncShopSubscriptions.call()
    end

    :ok
  end

  @doc """
  Enqueues a job to sync subscriptions for the given shop.
  """
  def enqueue(myshopify_domain) when is_binary(myshopify_domain),
    do: %{myshopify_domain: myshopify_domain} |> new() |> Oban.insert()
end
