defmodule ShopifyApp.Workflow.ShopUpdate do
  @moduledoc """
  Fetches the latest shop details from the Shopify Admin GraphQL API and
  persists them to the local shops DB record.
  """
  require Logger

  alias ShopifyApp.Model.Scope
  alias ShopifyApp.Shopify
  alias ShopifyApp.Shops

  @type t() :: %__MODULE__{myshopify_domain: String.t()}
  @enforce_keys [:myshopify_domain]
  defstruct @enforce_keys

  @spec call(t()) :: :ok | {:error, term()}
  def call(%{myshopify_domain: myshopify_domain} = context) when is_struct(context, __MODULE__) do
    with {:ok, scope} <- Scope.new(myshopify_domain),
         {:ok, shop_details} <- Shopify.Shop.get_details(scope),
         {:ok, _shop} <- Shops.update(scope.shop, %{shopify_shop_details: shop_details}) do
      :ok
    else
      {:error, error} = err ->
        Logger.error("ShopUpdate workflow failed #{inspect(error)}",
          myshopify_domain: myshopify_domain
        )

        err
    end
  end

  @spec new(Keyword.t()) :: t()
  def new(params), do: struct(__MODULE__, params)
end
