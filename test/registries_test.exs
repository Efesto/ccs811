defmodule Ccs811.RegistriesTest do
  use ExUnit.Case
  doctest Ccs811.Registries

  alias Ccs811.Registries

  describe "slave_address/0" do
    test "returns 0x5A by default" do
      :ok = Registries.init()
      assert Registries.slave_address() == 0x5A
    end

    test "returns new value when overridden" do
      :ok = Registries.init(slave_address: 0x5B)
      assert Registries.slave_address() == 0x5B
    end

    test "returns error when registries is not initialized" do
      assert_raise(RuntimeError, fn -> Registries.slave_address() end)
    end
  end
end
