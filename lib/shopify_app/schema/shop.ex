defmodule ShopifyApp.Schema.Shop do
  @moduledoc false
  use ShopifyApp.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "shops" do
    field :myshopify_domain, :string

    # Synced from Shopify via shop/update webhook
    field :shopify_shop_details, :map, default: %{}

    has_one :active_app_subscription, Schema.ShopSubscription,
      references: :myshopify_domain,
      foreign_key: :shop_myshopify_domain,
      where: [status: :active]

    has_many :shop_subscriptions, Schema.ShopSubscription,
      foreign_key: :shop_myshopify_domain,
      references: :myshopify_domain

    timestamps()
  end

  @doc false
  def changeset(shop, attrs) do
    shop
    |> cast(attrs, [:myshopify_domain, :shopify_shop_details])
    |> validate_required([:myshopify_domain])
  end
end
