defmodule Ccs811.Registries do
  @moduledoc """
  Represents the registries configuration, needs to be initialized
  """

  @table_name :registries_config
  @default_slave_address 0x5A
  @slave_address_key :slave_address

  def init(opts \\ []) do
    :ets.new(@table_name, [:set, :protected, :named_table])

    slave_address = Keyword.get(opts, :slave_address, @default_slave_address)
    :ets.insert(@table_name, {@slave_address_key, slave_address})

    :ok
  end

  def all() do
    %{
      status: %{address: 0x00, bytes: 1, read: true, write: false},
      meas_mode: %{address: 0x01, bytes: 1, read: true, write: true},
      alg_result_data: %{address: 0x02, bytes: 8, read: true, write: false},
      raw_data: %{address: 0x03, bytes: 2, read: true, write: false},
      env_data: %{address: 0x05, bytes: 4, read: false, write: true},
      ntc: %{address: 0x06, bytes: 4, read: true, write: false},
      thresholds: %{address: 0x10, bytes: 5, read: false, write: true},
      baseline: %{address: 0x11, bytes: 2, read: true, write: true},
      hw_id: %{address: 0x20, bytes: 1, read: true, write: false},
      hw_version: %{address: 0x21, bytes: 1, read: true, write: false},
      fw_boot_version: %{address: 0x23, bytes: 2, read: true, write: false},
      fw_app_version: %{address: 0x24, bytes: 2, read: true, write: false},
      error_id: %{address: 0xE0, bytes: 1, read: true, write: false},
      sw_reset: %{address: 0xFF, bytes: 4, read: false, write: true}
    }
  end

  def verify(), do: 0xF3
  def start(), do: 0xF4

  def slave_address() do
    [{@slave_address_key, slave_address}] = :ets.lookup(@table_name, :slave_address)
    slave_address
  rescue
    _ -> raise "#{__MODULE__} not initialized, use #{__MODULE__}.init before using it"
  end
end
