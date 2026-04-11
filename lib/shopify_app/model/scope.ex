defmodule ShopifyApp.Model.Scope do
  @moduledoc """
    Holds the request scope.

    The scope includes the app, shop and auth token for the user.
  """
  alias Phoenix.LiveView.AsyncResult
  alias ShopifyApp.Schema
  alias ShopifyApp.Shops

  @type t() :: admin_t()

  @type admin_t() :: %__MODULE__{
          app: ShopifyAPI.App.t(),
          auth_token: ShopifyAPI.AuthToken.t(),
          requested_at: NaiveDateTime.t(),
          shop: Schema.Shop.t(),
          shopifyapi_shop: ShopifyAPI.Shop.t(),
          user_token: %AsyncResult{}
        }

  defstruct [
    :app,
    :auth_token,
    :requested_at,
    :shop,
    :shopifyapi_shop,
    :user_token
  ]

  @spec new(String.t()) :: t() | {:error, any()}
  @spec new(
          ShopifyAPI.App.t(),
          ShopifyAPI.Shop.t(),
          ShopifyAPI.AuthToken.t() | nil,
          ShopifyAPI.UserToken.t() | nil,
          Schema.Shop.t() | nil
        ) :: t()
  def new(myshopify_domain) when is_binary(myshopify_domain) do
    with {:ok, shopifyapi_shop} <- ShopifyAPI.ShopServer.get(myshopify_domain),
         {:ok, app} <- ShopifyAPI.AppServer.get(ShopifyApp.Config.app_name()),
         {:ok, token} <-
           ShopifyAPI.AuthTokenServer.get(myshopify_domain, ShopifyApp.Config.app_name()),
         {:ok, shop} <- Shops.fetch(myshopify_domain) do
      new(app, shopifyapi_shop, token, nil, shop)
    end
  end

  def new(
        %ShopifyAPI.App{} = app,
        %ShopifyAPI.Shop{} = shopifyapi_shop,
        auth_token,
        user_token,
        shop
      ) do
    user_token =
      case user_token do
        %ShopifyAPI.UserToken{} = token -> AsyncResult.ok(token)
        _ -> AsyncResult.loading()
      end

    %__MODULE__{
      app: app,
      shop: shop,
      shopifyapi_shop: shopifyapi_shop,
      auth_token: auth_token,
      user_token: user_token,
      requested_at: NaiveDateTime.utc_now()
    }
  end

  def myshopify_domain(%__MODULE__{shopifyapi_shop: %ShopifyAPI.Shop{domain: domain}}),
    do: domain

  def myshopify_domain(%__MODULE__{shop: %Schema.Shop{myshopify_domain: domain}}), do: domain

  # cast/1 and equal?/2 are required to have this inside a changeset
  def cast(%__MODULE__{} = scope), do: {:ok, scope}
  def cast(nil), do: nil

  def equal?(a, b), do: a == b
end
