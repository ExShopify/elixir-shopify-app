defmodule ShopifyAppWeb.Unauthenticated.DashboardLive.Index do
  use ShopifyAppWeb, :unauthenticated_live_view
  import OctantisWeb.Components.Polaris
  require Logger

  alias ShopifyApp.Model

  alias ShopifyAPI.JWTSessionToken

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.s_box padding_block="large">
        <.s_section id="ReconnectSection">
          <.s_grid grid_template_columns="1fr auto" gap="base">
            <:s_grid_item>
              <.s_stack justify_content="space-between" gap="base">
                <.s_stack>
                  <.s_heading>Reconnecting session</.s_heading>
                  <.s_box>
                    Your session has temporariy been disconnected. If you are not automatically reconnected, click the button below.
                  </.s_box>
                </.s_stack>
                <a
                  id="LinkReturn"
                  data-phx-hook="UnauthenticatedRedirect"
                  phx-hook="UnauthenticatedRedirect"
                  href={@return_url}
                  target="_top"
                >
                  <.s_button
                    id="ButtonReturn"
                    href={@return_url}
                    target="_top"
                    loading={!@return_url}
                    disabled={!@return_url}
                  >
                    Click to reconnect
                  </.s_button>
                </a>
              </.s_stack>
            </:s_grid_item>
            <:s_grid_item>
              <.s_stack
                direction="inline"
                justify_content="center"
                align_items="center"
                padding="large"
              >
                <.s_spinner size="large-100" accessibility_label="reconnecting" />
              </.s_stack>
            </:s_grid_item>
          </.s_grid>
        </.s_section>
      </.s_box>
    </Layouts.app>
    """
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
        |> ShopifyApp.Config.shop_admin_app_uri()
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
end
