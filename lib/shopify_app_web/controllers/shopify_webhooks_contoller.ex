defmodule ShopifyAppWeb.ShopifyWebhooksController do
  use ShopifyAppWeb, :controller
  require Logger

  alias ShopifyAPI.Model.WebhookScope

  def webhook(
        %{
          assigns: %{
            webhook_scope: %WebhookScope{topic: "app_subscriptions/update"} = _webhook_scope
          }
        } = conn,
        params
      ) do
    Logger.info(
      "Subscription update on #{get_in(params, ["app_subscription", "name"])} to #{get_in(params, ["app_subscription", "status"])}"
    )

    json(conn, %{success: true})
  end

  def webhook(
        %{assigns: %{webhook_scope: %WebhookScope{topic: "app/uninstalled"} = webhook_scope}} =
          conn,
        _params
      ) do
    Logger.info("App uninstalled")
    ShopifyApp.Worker.Uninstall.App.enqueue(webhook_scope.myshopify_domain)

    json(conn, %{success: true})
  end

  def webhook(
        %{assigns: %{webhook_scope: %WebhookScope{topic: "shop/update"} = _webhook_scope}} =
          conn,
        _params
      ) do
    Logger.info("Shop update")

    json(conn, %{success: true})
  end

  def webhook(%{assigns: %{webhook_scope: %WebhookScope{} = webhook_scope}} = conn, _params) do
    Logger.warning("Unhandled webhook: #{inspect(webhook_scope.topic)}")
    json(conn, %{success: true})
  end
end
