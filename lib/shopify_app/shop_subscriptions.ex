defmodule ShopifyApp.ShopSubscriptions do
  @moduledoc """
  Context for managing shop subscriptions.
  """
  require Logger
  use ShopifyApp.Repo, define_types: ShopifyApp.Schema.ShopSubscription.t()

  alias ShopifyApp.Model
  alias ShopifyApp.Query
  alias ShopifyApp.Repo
  alias ShopifyApp.Schema

  @doc """
  Returns all subscriptions for a shop.
  """
  @spec all(Model.Scope.t()) :: list(t())
  def all(%Model.Scope{} = scope),
    do: scope |> Query.ShopSubscriptions.where_myshopify_domain() |> Repo.all()

  @doc """
  Returns all active subscriptions for a shop.
  """
  @spec all_active(Model.Scope.t()) :: list(t())
  def all_active(%Model.Scope{} = scope) do
    scope
    |> Query.ShopSubscriptions.where_myshopify_domain()
    |> Query.ShopSubscriptions.where_active()
    |> Repo.all()
  end

  @doc """
  Gets a subscription by Shopify ID and shop domain.

  Returns `nil` if not found.
  """
  @spec find(Model.Scope.t(), String.t()) :: t_or_nil()
  def find(%Model.Scope{} = scope, shopify_subscription_id) do
    scope
    |> Query.ShopSubscriptions.where_myshopify_domain()
    |> Query.ShopSubscriptions.where_shopify_id(shopify_subscription_id)
    |> Repo.one()
  end

  @doc """
  Gets a subscription by Shopify ID and shop domain, returning an error tuple.

  Returns `{:ok, subscription}` or `{:error, :not_found}`.
  """
  @spec fetch(Model.Scope.t(), String.t()) :: ok_error_not_found()
  def fetch(%Model.Scope{} = scope, shopify_subscription_id),
    do: scope |> find(shopify_subscription_id) |> Repo.ok_or_not_found()

  @doc """
  Gets the active subscription by myshopify domain.

  Returns `nil` if not found.
  """
  @spec find_active(String.t()) :: t_or_nil()
  def find_active(myshopify_domain) when is_binary(myshopify_domain) do
    myshopify_domain
    |> Query.ShopSubscriptions.where_myshopify_domain()
    |> Query.ShopSubscriptions.where_active()
    |> Repo.all()
    |> List.first()
  end

  @doc """
  Returns a changeset for validating subscription changes.
  """
  @spec change(t(), map()) :: Ecto.Changeset.t()
  def change(%Schema.ShopSubscription{} = subscription, attrs \\ %{}),
    do: Schema.ShopSubscription.changeset(subscription, attrs)

  @doc """
  Creates a subscription.
  """
  @spec create(map()) :: ok_changeset_error()
  def create(attrs), do: %Schema.ShopSubscription{} |> change(attrs) |> Repo.insert()

  @doc """
  Updates a subscription.
  """
  @spec update(t(), map()) :: ok_changeset_error()
  def update(%Schema.ShopSubscription{} = subscription, attrs),
    do: subscription |> Schema.ShopSubscription.changeset(attrs) |> Repo.update()

  @doc """
  Upserts a subscription by Shopify ID and shop domain.
  """
  @spec upsert(map()) :: ok_changeset_error()
  def upsert(
        %{subscription_id: _subscription_id, shop_myshopify_domain: _myshopify_domain} = attrs
      ) do
    %Schema.ShopSubscription{}
    |> Schema.ShopSubscription.changeset(attrs)
    |> Repo.insert(
      on_conflict:
        {:replace,
         [
           :status,
           :plan_name,
           :return_url,
           :currency_code,
           :price,
           :trial_ends_at,
           :billing_interval,
           :contract_updated_at,
           :raw_subscription_data,
           :updated_at
         ]},
      conflict_target: [:shop_myshopify_domain, :subscription_id]
    )
  end

  @doc """
  Marks active subscriptions not in the provided list as cancelled.

  Returns `{:ok, cancelled_subscription_ids}` on success, where `cancelled_subscription_ids`
  is a list of Shopify subscription IDs (GIDs) that were marked as cancelled.
  Returns `{:error, reason}` on failure.
  """
  @spec cancel_subscriptions_not_in_list(Model.Scope.t(), list(String.t())) ::
          {:ok, list(String.t())} | {:error, term()}
  def cancel_subscriptions_not_in_list(%Model.Scope{} = scope, active_subscription_ids) do
    # Get list of subscription IDs to cancel
    cancelled_subscriptions =
      scope
      |> Query.ShopSubscriptions.where_myshopify_domain()
      |> Query.ShopSubscriptions.where_active()
      |> Query.ShopSubscriptions.where_subscription_id_not_in(active_subscription_ids)
      |> Repo.all()

    case cancelled_subscriptions do
      [] ->
        {:ok, []}

      subscriptions_to_cancel ->
        cancelled_ids = Enum.map(subscriptions_to_cancel, & &1.subscription_id)

        {_count, _} =
          scope
          |> Query.ShopSubscriptions.where_myshopify_domain()
          |> Query.ShopSubscriptions.where_active()
          |> Query.ShopSubscriptions.where_subscription_id_not_in(active_subscription_ids)
          |> Repo.update_all(set: [status: :cancelled, updated_at: DateTime.utc_now()])

        {:ok, cancelled_ids}
    end
  end

  @doc """
  Updates a subscription's status from a webhook payload.

  Extracts the status from the app_subscription webhook data and updates the
  corresponding shop_subscription record if it exists.

  Returns `{:ok, subscription}` if the subscription was found and updated.
  Returns `{:error, :not_found}` if the subscription doesn't exist.
  Returns `{:error, reason}` if the update fails.
  """
  @spec update_status_from_webhook(Model.Scope.t(), map()) ::
          {:ok, t()} | {:error, :not_found | term()}
  def update_status_from_webhook(%Model.Scope{} = scope, app_subscription_data) do
    with subscription_id <- app_subscription_data["id"],
         new_status <- app_subscription_data["status"],
         {:ok, subscription} <- fetch(scope, subscription_id) do
      update(subscription, %{status: new_status})
    end
  end
end
