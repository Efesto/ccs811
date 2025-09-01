# Ccs811

![Elixir CI](https://github.com/Efesto/ccs811/workflows/Elixir%20CI/badge.svg)
[![Hex pm](https://img.shields.io/hexpm/v/ccs811.svg?style=flat)](https://hex.pm/packages/ccs811)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ccs811/)

Driver for CCS811 Ultra-Low Power Digital Gas Sensor for Monitoring Indoor Air Quality

[Datasheet](https://cdn.sparkfun.com/assets/learn_tutorials/1/4/3/CCS811_Datasheet-DS000459.pdf)

## Installation

The package can be installed by adding `ccs811` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ccs811, "~> 0.3.0"}
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
with a new data map containing values for eCO2 `:eco2` and TVOC `:tvoc`.

## Initialization

both [`Ccs811.start_polling()`](https://hexdocs.pm/ccs811/Ccs811.html#initialize/1) and [`Ccs811.initialize()`](https://hexdocs.pm/ccs811/Ccs811.html#initialize/1) supports additional configuration parameters that can be passed as a keyword list.

### Missing features

- Interrupt based data reading instead of polling
- Configuration for Bus-name (currently it uses the first available I2C bus)
