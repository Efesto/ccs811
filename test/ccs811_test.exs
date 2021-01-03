defmodule Ccs811Test do
  use ExUnit.Case
  doctest Ccs811

  describe "translate/2 meas_mode" do
    test "drive_mode_0" do
      data = <<12>>

      assert %{
               drive_mode: :mode_0,
               int_threshold: true,
               int_data_ready: true
             } == Ccs811.translate(data, :meas_mode)
    end

    [
      mode_0: <<12>>,
      mode_1: <<16>>,
      mode_2: <<32>>,
      mode_3: <<48>>,
      mode_4: <<64>>,
      reserved: <<80>>
    ]
    |> Enum.each(fn {expected_mode, data} ->
      @expected_mode expected_mode
      @data data
      test "drive mode #{expected_mode}" do
        assert %{drive_mode: @expected_mode} = Ccs811.translate(@data, :meas_mode)
      end
    end)
  end

  describe "translate/2 alg_result_data" do
    test "returns a map" do
      data = <<1, 144, 0, 0, 152, 0, 177, 147>>

      assert %{
               error_id: %{
                 heater_fault: false,
                 heater_supply: false,
                 max_resistance: false,
                 measmode_invalid: false,
                 red_reg_invalid: false,
                 write_reg_invalid: false
               },
               status: %{app_valid: true, data_ready: true, error: false, fw_mode: true},
               eco2: 400,
               tvoc: 0
             } = Ccs811.translate(data, :alg_result_data)
    end
  end
end
