defmodule ShopifyApp.Worker.Install.App do
  use Oban.Worker

  alias ShopifyApp.Workflow

  @impl Oban.Worker
  def perform(%_{args: %{"myshopify_domain" => myshopify_domain}}) do
    [myshopify_domain: myshopify_domain]
    |> Workflow.AppInstall.new()
    |> Workflow.AppInstall.call()

    :ok
  end

  def enqueue(%_{} = token),
    do: %{myshopify_domain: token.shop_name} |> new() |> Oban.insert()
end
