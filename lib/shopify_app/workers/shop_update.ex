defmodule ShopifyApp.Worker.ShopUpdate do
  use Oban.Worker

  alias ShopifyApp.Workflow

  @impl Oban.Worker
  def perform(%_{args: %{"myshopify_domain" => myshopify_domain}}) do
    [myshopify_domain: myshopify_domain]
    |> Workflow.ShopUpdate.new()
    |> Workflow.ShopUpdate.call()

    :ok
  end

  def enqueue(myshopify_domain) when is_binary(myshopify_domain),
    do: %{myshopify_domain: myshopify_domain} |> new() |> Oban.insert()
end
