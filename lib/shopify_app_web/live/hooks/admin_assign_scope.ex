defmodule ShopifyAppWeb.Hook.AdminAssignScope do
  @moduledoc """
  Handles session authentication for ShopAdmin LiveViews.
  This allows for patch navigation within a live_session.

  This has a prerequisite of the user being authenticated through
  the AuthShopSessionToken or AdminAuthenticator plug first
  and we have the app and shop in the assigns.
  We populate the session with the `app_name` and `myshopify_domain` from the assigns.
  We can now populate the socket assigns from the session and the respective servers.

  This is a good canditate for something that should be moved into ShopifyAPI.

  # Example

    live_session :my_session,
      session: {ShopifyAppWeb.Hook.AdminAssignScope, :session, []}
      on_mount: [ShopifyAppWeb.Hook.AdminAssignScope] do
        ...
    end
  """
  import Phoenix.Component

  alias ShopifyAPI.AppServer
  alias ShopifyAPI.AuthTokenServer
  alias ShopifyAPI.ShopServer
  alias ShopifyAPI.UserTokenServer
  alias ShopifyApp.Model
  alias ShopifyApp.Shops

  require Logger

  @doc """
  Pull app and shop out of the assigns to store it in the session.

  Session data is signed but not private so we are only storing the name and the domain.
  """
  def build_session(%{
        assigns: %{
          app: %ShopifyAPI.App{} = app,
          shop: %ShopifyAPI.Shop{} = shop,
          user_token: user_token
        }
      }) do
    associated_user_id = Map.get(user_token, :associated_user_id)

    %{
      "app_name" => app.name,
      "myshopify_domain" => shop.domain,
      "associated_user_id" => associated_user_id
    }
  end

  @doc """
  Build the assigns from the app name and the shop domain put in the session with build_session.
  """
  def on_mount(
        :default,
        _params,
        %{"app_name" => app_name, "myshopify_domain" => myshopify_domain} = session,
        socket
      ) do
    with {:ok, app} <- fetch_app(app_name),
         {:ok, shopifyapi_shop} <- fetch_shop(myshopify_domain),
         {:ok, shop} <- Shops.fetch(shopifyapi_shop.domain),
         {:ok, auth_token} <- AuthTokenServer.get(shopifyapi_shop.domain, app.name) do
      user_token =
        case UserTokenServer.get_valid(myshopify_domain, app_name, session["associated_user_id"]) do
          {:ok, token} -> token
          _ -> nil
        end

      scope =
        Model.Scope.new(
          app,
          shopifyapi_shop,
          auth_token,
          user_token,
          shop
        )

      {:cont, assign(socket, :scope, scope)}
    else
      {:error, error} ->
        Logger.error("Invalid session info #{inspect(error)}")
        {:halt, socket}
    end
  end

  def on_mount(:default, _params, _session, socket) do
    Logger.error("Missing session info")
    {:halt, socket}
  end

  defp fetch_shop(myshopify_domain) do
    case ShopServer.get(myshopify_domain) do
      {:ok, shop} -> {:ok, shop}
      :error -> {:error, :shop_not_found}
    end
  end

  defp fetch_app(app_name) do
    case AppServer.get(app_name) do
      {:ok, app} -> {:ok, app}
      :error -> {:error, :app_not_found}
    end
  end
end
