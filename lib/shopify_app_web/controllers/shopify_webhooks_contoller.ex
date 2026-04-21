defmodule ShopifyAppWeb.ShopifyWebhooksController do
  use ShopifyAppWeb, :controller
  require Logger

  alias ShopifyAPI.Model.WebhookScope
  alias ShopifyApp.Model
  alias ShopifyApp.ShopSubscriptions
  alias ShopifyApp.Worker

  def webhook(
        %{
          assigns: %{
            webhook_scope: %WebhookScope{topic: "app_subscriptions/update"} = webhook_scope
          }
        } = conn,
        params
      ) do
    app_subscription = params["app_subscription"]
    myshopify_domain = webhook_scope.myshopify_domain

    Logger.info(
      "Subscription update on #{app_subscription["name"]} to #{app_subscription["status"]}",
      myshopify_domain: myshopify_domain
    )

    case Model.Scope.new(myshopify_domain) do
      {:ok, scope} ->
        ShopSubscriptions.update_status_from_webhook(scope, app_subscription)

      {:error, error} ->
        Logger.warning("Failed to create scope for app subscription webhook: #{inspect(error)}",
          myshopify_domain: myshopify_domain
        )
    end

    # Always enqueue sync job for complete data refresh
    Worker.ShopSubscription.Sync.enqueue(myshopify_domain)

    json(conn, %{success: true})
  end

  def webhook(
        %{assigns: %{webhook_scope: %WebhookScope{topic: "app/uninstalled"} = webhook_scope}} =
          conn,
        _params
      ) do
    Logger.info("App uninstalled", myshopify_domain: webhook_scope.myshopify_domain)
    Worker.Uninstall.App.enqueue(webhook_scope.myshopify_domain)

    json(conn, %{success: true})
  end

  def webhook(
        %{assigns: %{webhook_scope: %WebhookScope{topic: "shop/update"} = webhook_scope}} =
          conn,
        _params
      ) do
    Logger.info("Shop update", myshopify_domain: webhook_scope.myshopify_domain)
    Worker.ShopUpdate.enqueue(webhook_scope.myshopify_domain)

    json(conn, %{success: true})
  end

  def webhook(%{assigns: %{webhook_scope: %WebhookScope{} = webhook_scope}} = conn, _params) do
    Logger.warning("Unhandled webhook: #{inspect(webhook_scope.topic)}")
    json(conn, %{success: true})
  end
end
