defmodule ShopifyApp.Repo.Migrations.CreateShops do
  use Ecto.Migration

  def change do
    create table(:shops) do
      add :myshopify_domain, :text

      timestamps()
    end

    create unique_index(:shops, [:myshopify_domain])
  end
end
