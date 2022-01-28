# Ccs811

![Elixir CI](https://github.com/Efesto/ccs811/workflows/Elixir%20CI/badge.svg)

Driver for CCS811 Ultra-Low Power Digital Gas Sensor for Monitoring Indoor Air Quality

[Datasheet](https://cdn.sparkfun.com/assets/learn_tutorials/1/4/3/CCS811_Datasheet-DS000459.pdf)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ccs811` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ccs811, "~> <LATEST_VERSION>"}
  ]
end
```

## Usage
### Standalone
```elixir
iex(1)> Ccs811.initialize
iex(2)> Ccs811.read_alg_result_data
%{
  eco2: 1529,
  error_id: %{
    heater_fault: false,
    heater_supply: false,
    max_resistance: false,
    measmode_invalid: false,
    red_reg_invalid: false,
    write_reg_invalid: false
  },
  status: %{app_valid: true, data_ready: true, error: false, fw_mode: true},
  tvoc: 191
}
iex(23)> Ccs811.read_status
%{app_valid: true, data_ready: true, error: false, fw_mode: true}
```

### With Telemetry

Add to your application initialization

```elixir
  Ccs811.start_polling()
```

Which will set the driver to periodically execute a telemetry event named `[:ccs811, :read]` 
with a new data map containing values for eCO2 `:eco2` and TVOC `tvoc`

## Initialization

both `Ccs811.start_polling()` and `Ccs811.initialize()` supports additional configuration parameters that can be passed as a keyword list

see `Ccs811.start_polling/1` and `Ccs811.initialize/1` for further details

### Missing features:
- Configuring humidity and temperature
- Interrupt based data reading instead of polling
- Configuration for Bus-name (currently it uses the first available I2C bus)
