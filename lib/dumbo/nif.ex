defmodule Dumbo.Nif do
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :dumbo_nif,
    crate: "dumbo_nif",
    base_url: "https://github.com/byhemechi/dumbo_nif/releases/download/v#{version}",
    version: version

  @doc """
  Decodes a numeric float token from the start of `source`.

  Returns `{:ok, {value, new_position}}` or `{:error, error}`.
  """
  def decode_numeric_float(_source), do: :erlang.nif_error(:nif_not_loaded)
end
