defmodule ShopifyApp.Schema.AuthToken do
  @moduledoc false
  use ShopifyApp.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "auth_tokens" do
    field :app_handle, :string
    field :plus, :boolean, default: false
    field :token, :string

    belongs_to :shop, Schema.Shop,
      references: :myshopify_domain,
      foreign_key: :shop_myshopify_domain,
      type: :string

    timestamps()
  end

  @doc false
  def changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [:app_handle, :shop_myshopify_domain, :token, :plus])
    |> validate_required([:app_handle, :shop_myshopify_domain, :token, :plus])
  end
end
