defmodule ShopifyApp.Workflow.AppInstall do
  @moduledoc """
  The AppInstall job handles all the install details after the tokens have been exchanged.
  """
  require Logger

  @type t() :: %__MODULE__{myshopify_domain: String.t()}
  @enforce_keys [:myshopify_domain]
  defstruct @enforce_keys

  @spec call(t()) :: :ok
  def call(%{myshopify_domain: myshopify_domain} = context) when is_struct(context, __MODULE__) do
    Logger.debug("New install", myshopify_domain: myshopify_domain)
    :ok
  end

  @spec new(Keyword.t()) :: t()
  def new(params), do: struct(__MODULE__, params)
end
