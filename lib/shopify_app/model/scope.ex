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

  @spec new(String.t()) :: {:ok, t()} | {:error, any()}
  @spec new(Schema.Shop.t()) :: {:ok, t()} | {:error, any()}
  @spec new(
          ShopifyAPI.App.t(),
          ShopifyAPI.Shop.t(),
          ShopifyAPI.AuthToken.t() | nil,
          ShopifyAPI.UserToken.t() | nil,
          Schema.Shop.t() | nil
        ) :: {:ok, t()}
  def new(%Schema.Shop{} = shop) do
    with {:ok, shopifyapi_shop} <- ShopifyAPI.ShopServer.get(shop.myshopify_domain),
         {:ok, app} <- ShopifyAPI.AppServer.get(ShopifyApp.Config.app_name()),
         {:ok, token} <-
           ShopifyAPI.AuthTokenServer.get(shop.myshopify_domain, ShopifyApp.Config.app_name()) do
      new(app, shopifyapi_shop, token, nil, shop)
    end
  end

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

    {:ok,
     %__MODULE__{
       app: app,
       shop: shop,
       shopifyapi_shop: shopifyapi_shop,
       auth_token: auth_token,
       user_token: user_token,
       requested_at: NaiveDateTime.utc_now()
     }}
  end

  @spec merge(t(), t()) :: t()
  def merge(%__MODULE__{} = old_scope, %__MODULE__{} = new_scope) do
    keep = Map.take(old_scope, [:user_token])
    Map.merge(new_scope, keep)
  end

  @spec add_user_token(t(), ShopifyAPI.UserToken.t()) :: t()
  @spec add_user_token(t(), integer()) :: t()
  def add_user_token(%__MODULE__{} = scope, %ShopifyAPI.UserToken{} = user_token),
    do: %{scope | user_token: AsyncResult.ok(scope.user_token, user_token)}

  def add_user_token(%__MODULE__{} = scope, associated_user_id)
      when is_integer(associated_user_id) do
    case ShopifyAPI.UserTokenServer.get_valid(
           myshopify_domain(scope),
           app_name(scope),
           associated_user_id
         ) do
      {:ok, user_token} -> add_user_token(scope, user_token)
      _ -> scope
    end
  end

  def add_shop(%__MODULE__{} = scope, %Schema.Shop{} = shop), do: %{scope | shop: shop}

  def app_name(%__MODULE__{app: %ShopifyAPI.App{name: name}}), do: name

  def myshopify_domain(%__MODULE__{shopifyapi_shop: %ShopifyAPI.Shop{domain: domain}}),
    do: domain

  def myshopify_domain(%__MODULE__{shop: %Schema.Shop{myshopify_domain: domain}}), do: domain

  @spec shop_slug(t()) :: String.t()
  def shop_slug(%__MODULE__{} = scope),
    do: scope |> myshopify_domain() |> ShopifyAPI.Shop.slug_from_domain()

  # cast/1 and equal?/2 are required to have this inside a changeset
  def cast(%__MODULE__{} = scope), do: {:ok, scope}
  def cast(nil), do: nil

  def equal?(a, b), do: a == b
end

defimpl ShopifyAPI.Scope, for: ShopifyApp.Model.Scope do
  def shop(%{shopifyapi_shop: shop}), do: shop
  def app(%{app: app}), do: app
  def auth_token(%{auth_token: auth_token}), do: auth_token
  def user_token(%{user_token: user_token}), do: user_token
end
