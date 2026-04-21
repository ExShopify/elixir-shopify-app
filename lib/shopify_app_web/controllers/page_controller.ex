defmodule ShopifyAppWeb.PageController do
  use ShopifyAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
