defmodule Ccs811 do
  alias Circuits.I2C
  alias Ccs811.Registries

  use Bitwise

  Registries.all()
  |> Enum.filter(fn {_, %{read: read}} -> read end)
  |> Enum.each(fn {key, %{address: address, bytes: bytes}} ->
    def unquote(:"read_#{key}")() do
      with {:ok, data} <- read_registry(unquote(address), unquote(bytes)) do
        translate(data, unquote(key))
      end
    end
  end)

  Registries.all()
  |> Enum.filter(fn {_, %{write: write}} -> write end)
  |> Enum.each(fn {key, %{address: address, bytes: bytes}} ->
    def unquote(:"write_#{key}")(data) when byte_size(data) == unquote(bytes) do
      write_registry(unquote(address), data)
    end
  end)

  def initialize() do
    app_start()
    set_meas_mode(:mode_1)
  end

  def start_polling() do
    Ccs811.Telemetry.start_polling()
  end

  def app_verify(), do: write_registry(Registries.verify())
  def app_start(), do: write_registry(Registries.start())

  # MEAS - Measurement and Conditions
  def set_meas_mode(:mode_0), do: write_meas_mode(<<0>>)
  def set_meas_mode(:mode_1), do: write_meas_mode(<<16>>)
  def set_meas_mode(:mode_2), do: write_meas_mode(<<32>>)
  def set_meas_mode(:mode_3), do: write_meas_mode(<<48>>)
  def set_meas_mode(:mode_4), do: write_meas_mode(<<64>>)

  def translate(<<data>>, :status) do
    %{
      fw_mode: data |> bit_mask_to_boolean(128),
      app_valid: data |> bit_mask_to_boolean(16),
      data_ready: data |> bit_mask_to_boolean(8),
      error: data |> bit_mask_to_boolean(1)
    }
  end

  def translate(<<data>>, :meas_mode) do
    drive_mode =
      case data &&& 112 do
        0 -> :mode_0
        16 -> :mode_1
        32 -> :mode_2
        48 -> :mode_3
        64 -> :mode_4
        _ -> :reserved
      end

    %{
      drive_mode: drive_mode,
      int_threshold: data |> bit_mask_to_boolean(4),
      int_data_ready: data |> bit_mask_to_boolean(8)
    }
  end

  def translate(<<data>>, :error_id) do
    %{
      write_reg_invalid: data |> bit_mask_to_boolean(1),
      red_reg_invalid: data |> bit_mask_to_boolean(2),
      measmode_invalid: data |> bit_mask_to_boolean(4),
      max_resistance: data |> bit_mask_to_boolean(8),
      heater_fault: data |> bit_mask_to_boolean(16),
      heater_supply: data |> bit_mask_to_boolean(32)
    }
  end

  def translate(
        <<eco2_high_byte, eco2_low_byte, tvoc_high_byte, tvoc_low_byte, status, error_id,
          _raw_data1, _raw_data2>>,
        :alg_result_data
      ) do
    <<eco2::16>> = <<eco2_high_byte, eco2_low_byte>>
    <<tvoc::16>> = <<tvoc_high_byte, tvoc_low_byte>>

    %{
      status: translate(<<status>>, :status),
      error_id: translate(<<error_id>>, :error_id),
      eco2: eco2,
      tvoc: tvoc
    }
  end

  def translate(<<major::4, minor::4, trivial>>, :fw_app_version) do
    "#{major}.#{minor}.#{trivial}"
  end

  def translate(<<data>>, _), do: data

  defp bit_mask_to_boolean(value, mask) do
    (value &&& mask) > 0
  end

  def read_registry(address, bytes) do
    open()
    |> I2C.write_read(Registries.slave_address(), [address], bytes)
  end

  def write_registry(address, data) do
    open()
    |> I2C.write(Registries.slave_address(), [address, data])
  end

  def write_registry(address) do
    open()
    |> I2C.write(Registries.slave_address(), [address])
  end

  defp open do
    with {:ok, bus_name} <- get_i2c_bus_name(),
         {:ok, ref} <- I2C.open(bus_name) do
      ref
    else
      {:error, :no_bus_names} ->
        raise "No I2C bus names found, check https://github.com/elixir-circuits/circuits_i2c#how-do-i-debug for info"

      {:error, error} ->
        raise "Unable to open I2C bus - #{inspect(error)}"
    end
  end

  defp get_i2c_bus_name do
    case Circuits.I2C.bus_names() do
      [] -> {:error, :no_bus_names}
      [first_available_bus_name | _] -> {:ok, first_available_bus_name}
    end
  end
end
