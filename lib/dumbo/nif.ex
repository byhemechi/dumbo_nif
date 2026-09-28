defmodule Dumbo.Nif do
  @moduledoc false

  use Rustler, otp_app: :dumbo_nif, crate: "dumbo_nif"

  @doc """
  Decodes a numeric float token from the start of `source`.

  Returns `{:ok, {value, new_position}}` or `{:error, error}`.
  """
  def decode_numeric_float(_source), do: :erlang.nif_error(:nif_not_loaded)
end
