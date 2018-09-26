use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixir_list, ElixirListWeb.Endpoint,
  http: [port: 4001],
  server: false,
  dets: :store_test

# Print only warnings and errors during test
config :logger, level: :warn
