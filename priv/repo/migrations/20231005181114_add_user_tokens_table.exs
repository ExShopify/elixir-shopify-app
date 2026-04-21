defmodule ShopifyApp.Repo.Migrations.AddUserTokensTable do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :app_handle, :text
      add :code, :text
      add :token, :text
      add :associated_user_id, :bigint
      add :associated_user_scope, :text
      add :timestamp, :bigint
      add :plus, :boolean
      add :scope, :text
      add :expires_in, :bigint
      add :associated_user, :map

      add :shop_myshopify_domain,
          references(:shops, column: :myshopify_domain, type: :text, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:user_tokens, :associated_user_id)
    create index(:user_tokens, [:shop_myshopify_domain, :app_handle])
  end
end
