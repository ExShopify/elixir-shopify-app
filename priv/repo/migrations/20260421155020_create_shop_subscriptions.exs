defmodule ShopifyApp.Repo.Migrations.CreateShopSubscriptions do
  use Ecto.Migration

  def change do
    create table(:shop_subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :shop_myshopify_domain,
          references(:shops, column: :myshopify_domain, type: :text, on_delete: :delete_all),
          null: false

      add :subscription_id, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :plan_name, :string
      add :return_url, :text
      add :currency_code, :string
      add :price, :numeric
      add :price_after_discount, :numeric
      add :trial_days, :integer
      add :trial_ends_at, :utc_datetime
      add :billing_interval, :string
      add :contract_updated_at, :utc_datetime
      add :raw_subscription_data, :map
      add :test, :boolean, default: false

      timestamps()
    end

    create index(:shop_subscriptions, [:shop_myshopify_domain])
    create unique_index(:shop_subscriptions, [:shop_myshopify_domain, :subscription_id])
  end
end
