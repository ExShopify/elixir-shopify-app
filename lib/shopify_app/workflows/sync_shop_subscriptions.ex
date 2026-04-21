defmodule ShopifyApp.Workflow.SyncShopSubscriptions do
  @moduledoc """
  Fetches the current active subscriptions from Shopify's currentAppInstallation query
  and syncs them to the local shop_subscriptions table.

  Handles creating new subscriptions, updating existing ones, and marking cancelled
  subscriptions.
  """
  require Logger

  alias ShopifyApp.Model
  alias ShopifyApp.Shopify
  alias ShopifyApp.ShopSubscriptions

  @type t() :: %__MODULE__{scope: Model.Scope.t()}
  @enforce_keys [:scope]
  defstruct @enforce_keys

  @spec call(t()) :: :ok | {:error, term()}
  def call(%{scope: %Model.Scope{} = scope} = context) when is_struct(context, __MODULE__) do
    with {:ok, remote_subscriptions} <- Shopify.Subscription.fetch_current_subscriptions(scope) do
      Enum.each(remote_subscriptions, &upsert_subscription(scope, &1))

      # Extract subscription IDs from the remote response
      active_subscription_ids = Enum.map(remote_subscriptions, & &1["id"])

      # Mark any active subscriptions not in the response as cancelled
      with {:ok, cancelled_ids} <-
             ShopSubscriptions.cancel_subscriptions_not_in_list(scope, active_subscription_ids) do
        log_sync_completion(scope, cancelled_ids)
      end

      :ok
    else
      {:error, error} = err ->
        Logger.error("SyncShopSubscriptions workflow failed: #{inspect(error)}",
          myshopify_domain: Model.Scope.myshopify_domain(scope)
        )

        err
    end
  end

  @spec new(Keyword.t()) :: t()
  def new(params), do: struct(__MODULE__, params)

  defp upsert_subscription(scope, subscription_data) do
    attrs = scope |> Model.Scope.myshopify_domain() |> parse_subscription_data(subscription_data)

    case ShopSubscriptions.upsert(attrs) do
      {:ok, _subscription} ->
        Logger.info(
          "Synced subscription (#{subscription_data["id"]}, #{subscription_data["status"]})",
          myshopify_domain: Model.Scope.myshopify_domain(scope)
        )

      {:error, error} ->
        Logger.error(
          "Failed to upsert subscription (#{subscription_data["id"]}): #{inspect(error)}",
          myshopify_domain: Model.Scope.myshopify_domain(scope)
        )
    end
  end

  defp parse_subscription_data(myshopify_domain, subscription_data) do
    %{
      shop_myshopify_domain: myshopify_domain,
      subscription_id: subscription_data["id"],
      status: parse_status(subscription_data["status"]),
      plan_name: subscription_data["name"],
      return_url: subscription_data["returnUrl"],
      currency_code: get_in(subscription_data, ["pricingDetails", "currencyCode"]),
      price: get_in(subscription_data, ["pricingDetails", "price", "amount"]),
      price_after_discount:
        get_in(subscription_data, ["pricingDetails", "discount", "priceAfterDiscount", "amount"]),
      billing_interval:
        parse_billing_interval(get_in(subscription_data, ["pricingDetails", "interval"])),
      trial_days: get_in(subscription_data, ["trialDays"]),
      trial_ends_at: parse_datetime(subscription_data["trialDays"]),
      contract_updated_at: parse_datetime(subscription_data["updatedAt"]),
      test: get_in(subscription_data, ["test"]),
      raw_subscription_data: subscription_data
    }
  end

  defp parse_status(status_str) when is_binary(status_str) do
    status_str
    |> String.downcase()
    |> String.to_atom()
  end

  defp parse_status(_), do: :pending

  defp parse_billing_interval(interval_str) when is_binary(interval_str) do
    case String.downcase(interval_str) do
      "annual" -> :annual
      "monthly" -> :monthly
      "every_30_days" -> :every_30_days
      _ -> nil
    end
  end

  defp parse_billing_interval(_), do: nil

  defp parse_datetime(nil), do: nil

  defp parse_datetime(datetime_str) when is_binary(datetime_str) do
    case DateTime.from_iso8601(datetime_str) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> nil
    end
  end

  defp parse_datetime(_), do: nil

  defp log_sync_completion(scope, cancelled_ids) do
    case cancelled_ids do
      [] ->
        Logger.info("SyncShopSubscriptions workflow completed",
          myshopify_domain: Model.Scope.myshopify_domain(scope)
        )

      ids ->
        Logger.info(
          "SyncShopSubscriptions workflow completed, marked #{length(ids)} subscriptions as cancelled",
          myshopify_domain: Model.Scope.myshopify_domain(scope)
        )
    end
  end
end
