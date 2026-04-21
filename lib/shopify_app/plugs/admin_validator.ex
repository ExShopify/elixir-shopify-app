defmodule ShopifyApp.Plug.AdminValidator do
  @moduledoc """
  If we do not have a proper hmac, we redirect to `/unauthenticated` to handle this.
  """

  def init(opts), do: opts

  def call(%{assigns: %{app: %ShopifyAPI.App{}, shop: %ShopifyAPI.Shop{}}} = conn, _options),
    do: conn

  def call(%{assigns: _} = conn, _options) do
    redirect =
      URI.parse("/unauthenticated")
      |> URI.append_query(URI.encode_query(request_path: conn.request_path))
      |> URI.append_query(URI.encode_query(query_string: conn.query_string))
      |> to_string()

    conn
    |> Phoenix.Controller.redirect(to: redirect)
    |> Plug.Conn.halt()
  end
end
