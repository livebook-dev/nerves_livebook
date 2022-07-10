defmodule NervesLivebook.MixProject do
  use Mix.Project

  @app :nerves_livebook
  @version "0.6.2"

  @rpi_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4]
  @all_targets @rpi_targets ++ [:bbb, :osd32mp1, :x86_64, :npi_imx6ull, :grisp2, :mangopi_mq_pro]

  # Libraries that use MMAL on the Raspberry Pi won't work with the Raspberry
  # Pi 4. The Raspberry Pi 4 uses DRM and libcamera.
  @rpi_mmal_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a]

  # See the BlueHeron repository for the boards that it supports.
  @ble_targets [:rpi0, :rpi3, :rpi3a]

  def project do
    [
      app: @app,
      description: "Develop on embedded devices with Livebook and Nerves",
      author: "https://github.com/livebook-dev/nerves_livebook/graphs/contributors",
      version: @version,
      elixir: "~> 1.13",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host, "phx.server": :host],
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      mod: {NervesLivebook.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets, :ex_unit]
    ]
  end

  defp deps do
    [
      # Dependencies for host and target
      {:nerves, "~> 1.8.0", runtime: false},
      {:shoehorn, "~> 0.9.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},
      {:jason, "~> 1.2"},
      {:nerves_runtime, "~> 0.13.0"},
      {:livebook, "~> 0.6.2"},
      {:plug, "~> 1.12"},

      # Pull in commonly used libraries as a convenience to users.
      {:blue_heron, "~> 0.3", override: true, targets: @ble_targets},
      {:blue_heron_transport_uart, "~> 0.1.2", targets: @ble_targets},
      {:bmp280, "~> 0.2", targets: @all_targets},
      {:circuits_gpio, "~> 1.0"},
      {:circuits_i2c, "~> 1.0"},
      {:circuits_spi, "~> 1.0 or ~> 0.1"},
      {:circuits_uart, "~> 1.3"},
      {:input_event, "~> 1.0 or ~> 0.4", targets: @all_targets},
      {:kino, "~> 0.6"},
      {:kino_maplibre, "~> 0.1.0"},
      {:kino_vega_lite, "~> 0.1.1"},
      {:maplibre, "~> 0.1.0"},
      {:nerves_key, "~> 1.0", targets: @all_targets},
      {:nerves_pack, "~> 0.7.0", targets: @all_targets},
      {:nerves_time_zones, "~> 0.2.0", targets: @all_targets},
      {:nx, "~> 0.2.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:picam, "~> 0.4.0", targets: @rpi_mmal_targets},
      {:pigpiox, "~>0.1", targets: @rpi_targets},
      {:ramoops_logger, "~> 0.1", targets: @all_targets},
      {:req, "~> 0.3.0"},
      {:scroll_hat, "~> 0.1", targets: @rpi_targets},
      {:vega_lite, "~> 0.1"},

      # Nerves system dependencies
      {:nerves_system_rpi, "~> 1.18", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.18", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.18", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.18", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.18", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.18", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.13", runtime: false, targets: :bbb},
      {:nerves_system_osd32mp1, "~> 0.9", runtime: false, targets: :osd32mp1},
      {:nerves_system_x86_64, "~> 1.18", runtime: false, targets: :x86_64},
      {:nerves_system_npi_imx6ull, "~> 0.5", runtime: false, targets: :npi_imx6ull},
      {:nerves_system_grisp2, "~> 0.2", runtime: false, targets: :grisp2},
      {:nerves_system_mangopi_mq_pro, "~> 0.1", runtime: false, targets: :mangopi_mq_pro},

      # Compile-time only
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:sbom, "~> 0.6", only: :dev, runtime: false}
    ]
  end

  def release do
    [
      overwrite: true,
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: [keep: ["Docs"]]
    ]
  end

  defp dialyzer() do
    [
      flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end
end
