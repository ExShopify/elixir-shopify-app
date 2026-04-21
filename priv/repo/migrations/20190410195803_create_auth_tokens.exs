defmodule ShopifyApp.Repo.Migrations.CreateAuthTokens do
  use Ecto.Migration

  def change do
    create table(:auth_tokens) do
      add :app_handle, :text
      add :token, :text
      add :plus, :boolean, default: false, null: false

      add :shop_myshopify_domain,
          references(:shops, column: :myshopify_domain, type: :text, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:auth_tokens, [:shop_myshopify_domain, :app_handle])
  end
end
