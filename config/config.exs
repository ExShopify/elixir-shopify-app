# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :shopify_app, ShopifyApp.Repo, migration_primary_key: [type: :binary_id]

config :shopify_app,
  ecto_repos: [ShopifyApp.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure the endpoint
config :shopify_app, ShopifyAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ShopifyAppWeb.ErrorHTML, json: ShopifyAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ShopifyApp.PubSub,
  live_view: [signing_salt: "ohBcnlqz"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :shopify_app, ShopifyApp.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  shopify_app: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  shopify_app: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time [$level] $message [$metadata]\n",
  metadata: [:request_id, :mta, :error, :myshopify_domain, :shopify_object_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :shopify_app, ShopifyApp.Config,
  shopify_config_file:
    Path.join([
      __ENV__.file |> Path.expand() |> Path.dirname(),
      "..",
      "app-extension",
      "shopify.app.toml"
    ])

###################
# ShopifyAPI Config
###################
config :shopify_api, ShopifyAPI.AuthTokenServer,
  initializer: {ShopifyApp.ShopifyAPI.Initializer, :auth_token_init, []},
  persistence: {ShopifyApp.ShopifyAPI.Initializer, :auth_token_persist, []}

config :shopify_api, ShopifyAPI.UserTokenServer,
  initializer: {ShopifyApp.ShopifyAPI.Initializer, :user_token_init, []},
  persistence: {ShopifyApp.ShopifyAPI.Initializer, :user_token_persist, []}

config :shopify_api, ShopifyAPI.AppServer,
  initializer: {ShopifyApp.ShopifyAPI.Initializer, :app_init, []},
  persistence: nil

config :shopify_api, ShopifyAPI.ShopServer,
  initializer: {ShopifyApp.ShopifyAPI.Initializer, :shop_init, []},
  persistence: {ShopifyApp.ShopifyAPI.Initializer, :shop_persist, []}

config :shopify_api, ShopifyAPI.Shop, post_login: {ShopifyApp.ShopifyAPI.PostLoginHook, :call, []}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
