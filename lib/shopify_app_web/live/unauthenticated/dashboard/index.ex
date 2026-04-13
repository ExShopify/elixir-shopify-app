defmodule ShopifyAppWeb.Unauthenticated.DashboardLive.Index do
  use ShopifyAppWeb, :unauthenticated_live_view

  import OctantisWeb.Components.Polaris

  alias ShopifyApp.Model

  alias ShopifyAPI.JWTSessionToken

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"query_string" => query_string, "request_path" => request_path},
        _url,
        socket
      ) do
    {:noreply,
     socket
     |> assign(:request_path, request_path)
     |> assign(:query_string, query_string)
     |> assign(:return_url, nil)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:request_path, "/live_shop_admin")
     |> assign(:query_string, "")
     |> assign(:return_url, nil)}
  end

  @impl true
  def handle_event(
        "ShopifyUserToken:mounted",
        %{"session_token" => session_token} = _params,
        socket
      ) do
    app = ShopifyAPI.Config.app()

    with {true, jwt, _jws} <- JWTSessionToken.verify(session_token, app.client_secret),
         {:ok, myshopify_domain} <- JWTSessionToken.myshopify_domain(jwt),
         {:ok, scope} <- Model.Scope.new(myshopify_domain) do
      return_url =
        scope
        |> shop_base()
        |> URI.append_path("/admin/apps/")
        |> URI.append_path("/" <> app.handle)
        |> URI.append_path(socket.assigns.request_path)
        |> URI.append_query(socket.assigns.query_string)
        |> to_string()

      {:noreply,
       socket |> assign(:return_url, return_url) |> push_event("UnauthenticatedRedirect", %{})}
    else
      error ->
        Logger.error("Unauthenticated Dashboard failed to reddirect. #{inspect(error)}")
        %JOSE.JWT{fields: %{"iss" => issuer}} = JOSE.JWT.peek_payload(session_token)

        {:noreply,
         socket |> assign(:return_url, issuer) |> push_event("UnauthenticatedRedirect", %{})}
    end
  end

  def shop_base(%Model.Scope{} = scope) do
    # TODO revert this back to, when issue: https://github.com/jeremyjh/dialyxir/issues/571
    # @admin_shopify_uri
    # |> URI.append_path("/store")
    # |> URI.append_path("/" <> shop_slug)
    shop_slug = scope |> Model.Scope.shop_slug()
    URI.new!("https://admin.shopify.com/store/#{shop_slug}")
  end
end
