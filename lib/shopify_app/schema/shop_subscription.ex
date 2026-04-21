defmodule ShopifyApp.Schema.ShopSubscription do
  @moduledoc """
  Represents a Shopify app subscription for a shop.
  Synced from Shopify's `AppSubscription` via webhooks and the `currentAppInstallation` query.
  """
  use ShopifyApp.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @statuses [:pending, :active, :cancelled, :failed, :expired, :declined]
  @billing_intervals [:annual, :monthly, :every_30_days]

  schema "shop_subscriptions" do
    field :subscription_id, :string
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :plan_name, :string
    field :return_url, :string
    field :currency_code, :string
    field :price, :decimal
    field :price_after_discount, :decimal
    field :trial_days, :integer, default: 0
    field :trial_ends_at, :utc_datetime
    field :billing_interval, Ecto.Enum, values: @billing_intervals
    field :contract_updated_at, :utc_datetime
    field :raw_subscription_data, :map
    field :test, :boolean, default: false

    belongs_to :shop, Schema.Shop,
      references: :myshopify_domain,
      foreign_key: :shop_myshopify_domain,
      type: :string

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :subscription_id,
      :shop_myshopify_domain,
      :status,
      :plan_name,
      :return_url,
      :currency_code,
      :price,
      :trial_ends_at,
      :billing_interval,
      :contract_updated_at,
      :raw_subscription_data
    ])
    |> validate_required([:subscription_id, :shop_myshopify_domain])
    |> unique_constraint([:shop_myshopify_domain, :subscription_id])
  end
end
