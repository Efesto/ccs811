defmodule Ccs811.Telemetry do
  use DynamicSupervisor

  @poller_name :ccs811_poller
  @default_polling_period 30

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Starts a periodic poller that generates telemetry events containing the sensor readings

  It supports additional arguments:

  `:period` - polling period in seconds, default: #{@default_polling_period}

  Any other additional argument will be passed to `Ccs811.initialize()`

  Example:
  ```
  Ccs811.start_polling(period: 60)
  ```
  """
  def start_polling(args) do
    {period, args} = Keyword.pop(args, :period, @default_polling_period)

    opts = [
      measurements: [{__MODULE__, :poll_read, []}],
      period: :timer.seconds(period),
      name: @poller_name
    ]

    spec = :telemetry_poller.child_spec(opts)

    :ok = Ccs811.initialize(args)

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_polling() do
    @poller_name
    |> GenServer.whereis()
    |> case do
      nil -> {:error, :not_found}
      poller -> DynamicSupervisor.terminate_child(__MODULE__, poller)
    end
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def poll_read() do
    case Ccs811.read_alg_result_data() do
      %{status: %{error: false}} = reading ->
        :telemetry.execute([:ccs811, :read], reading, %{})

      _ ->
        nil
    end
  end
end
