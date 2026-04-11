alias ShopifyApp.Repo
alias ShopifyApp.Shops

defmodule IEXHelpers do
  def to_atom(%ShopifyApp.Schema.Shop{} = shop),
    do: shop.myshopify_domain |> String.replace("-", "_") |> String.to_atom()

  def get_token(%ShopifyApp.Schema.Shop{myshopify_domain: domain}),
    do: ShopifyApp.AuthTokens.find(domain)

  def format_shops_msg(shops) do
    shops_list_str =
      shops
      |> Enum.map(&("   - #{elem(&1, 0)}: " <> elem(&1, 1).myshopify_domain))
      |> Enum.join("\n")

    shops_header = IO.ANSI.format([:bright, :green, "LOADED in to the `shops` map:"])
    IO.chardata_to_string(shops_header) <> "\n" <> shops_list_str
  end
end

shops = Shops.all() |> Map.new(fn shop -> {IEXHelpers.to_atom(shop), shop} end)
tokens = Map.new(shops, fn {key, shop} -> {key, IEXHelpers.get_token(shop)} end)
shops |> IEXHelpers.format_shops_msg() |> IO.puts()

import_file_if_available(".iex.private.exs")
