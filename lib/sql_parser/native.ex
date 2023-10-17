defmodule SQLParser.Native do
  @moduledoc false

  use Rustler, otp_app: :sql_parser, crate: :sql_parser

  def parse(_sql, _dialect), do: :erlang.nif_error(:nif_not_loaded)

  def to_sql(_ast), do: :erlang.nif_error(:nif_not_loaded)
end
