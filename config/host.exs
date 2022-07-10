import Config

config :nerves_runtime,
  target: "host"

# Configure Nerves runtime dependencies for the host
config :nerves_runtime, Nerves.Runtime.KV.Mock, %{"nerves_fw_devpath" => "/dev/will_not_work"}
