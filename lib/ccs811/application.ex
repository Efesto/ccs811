defmodule Ccs811.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Ccs811.Supervisor]

    children = [
      Ccs811.Telemetry
    ]

    Supervisor.start_link(children, opts)
  end
end
