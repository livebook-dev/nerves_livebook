defmodule NervesLivebook.UI do
  @moduledoc """
  Provide a simple UI using the device's built-in LEDs

  Livebook, of course, is the main UI. This module handles one LED for now
  since every supported device has one.
  """
  use GenServer
  alias NervesLivebook.PatternLED

  require Logger

  @typedoc false
  @type option() :: {:led, String.t()}

  @doc """
  Start the UI GenServer

  Options:

  * `:led` - the name of the LED to use (like "led0" for the Raspberry Pis)
  """
  @spec start_link([option]) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    with {:ok, led} <- Keyword.fetch(opts, :led),
         true <- is_binary(led),
         :ok <- PatternLED.initialize_led(led) do
      setup_led(led)

      {:ok, led}
    else
      _ ->
        # No LED configured, so just carry on and don't do anything.
        Logger.info("NervesLivebook: No LED configured or error so not showing device status")
        :ignore
    end
  end

  @impl GenServer
  def handle_info({VintageNet, ["connection"], _old, value, _meta}, led) do
    update_led(led, value)
    {:noreply, led}
  end

  defp update_led(led, network_connection) do
    with {:ok, brightness} <- PatternLED.get_max_brightness(led),
         pattern = network_connection_to_led(brightness, network_connection),
         :ok <- PatternLED.set_led_pattern(led, pattern) do
      :ok
    else
      {:error, reason} ->
        Logger.info("NervesLivebook failed to set LED '#{led}': #{inspect(reason)}")
    end
  end

  if Mix.target() == :host do
    defp setup_led(_led), do: :ok
  else
    defp setup_led(led) do
      VintageNet.subscribe(["connection"])
      update_led(led, VintageNet.get(["connection"]))
    end
  end

  defp network_connection_to_led(brightness, :lan), do: PatternLED.on(brightness)
  defp network_connection_to_led(brightness, :internet), do: PatternLED.on(brightness)
  defp network_connection_to_led(brightness, _other), do: PatternLED.blink(brightness, 4)
end
