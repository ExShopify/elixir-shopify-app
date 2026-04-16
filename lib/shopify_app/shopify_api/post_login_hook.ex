defmodule ShopifyApp.ShopifyAPI.PostLoginHook do
  require Logger
  alias ShopifyApp.Worker

  @spec call(ShopifyAPI.AuthToken.t()) :: any()
  @spec call(ShopifyAPI.UserToken.t()) :: any()
  def call(%ShopifyAPI.AuthToken{} = token), do: Worker.Install.App.enqueue(token)

  def call(%ShopifyAPI.UserToken{myshopify_domain: myshopify_domain, associated_user: user}),
    do: Logger.debug("Login: #{user.email}", myshopify_domain: myshopify_domain)
end
