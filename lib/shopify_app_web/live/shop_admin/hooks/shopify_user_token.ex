defmodule ShopifyAppWeb.ShopAdmin.Hooks.ShopifyUserToken do
  @moduledoc """
  The ShopifyUserToken Hook (on <main/> in app.html.heex) sends up the
  shopify session token (shopify.idToken()) to ShopifyUserToken:mounted
  This adds a handle_event for ShopifyUserToken:mounted

  The session token is exchanged for a user token.
  The user token is then stored in the UserTokenServer and the Scope.
  """
  require Logger

  import Phoenix.Component
  import Phoenix.LiveView, only: [put_flash: 3]

  alias ShopifyApp.Model.Scope

  alias ShopifyAPI.JWTSessionToken

  @flash_error_message "Failed authenticating user session, please reload page."

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> Phoenix.LiveView.attach_hook(:shopify_user_token, :handle_event, fn
        "ShopifyUserToken:mounted", %{"session_token" => session_token} = params, socket ->
          scope = socket.assigns.scope

          with {true, jwt, _jws} <-
                 JWTSessionToken.verify(session_token, scope.app.client_secret),
               {:ok, new_user_token} <- JWTSessionToken.get_user_token(jwt, session_token) do
            scope = Scope.add_user_token(scope, new_user_token)
            {:halt, params, assign(socket, :scope, scope)}
          else
            {false, _, _} ->
              Logger.warning("Failed validation of session token")
              {:halt, params, put_flash(socket, :error, @flash_error_message)}

            {:error, :invalid_session_token} ->
              {:halt, params, put_flash(socket, :error, @flash_error_message)}

            {:error, :failed_fetching_online_token} ->
              {:halt, params, put_flash(socket, :error, @flash_error_message)}
          end

        _, _, socket ->
          {:cont, socket}
      end)

    {:cont, socket}
  end
end
