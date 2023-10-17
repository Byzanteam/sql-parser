defmodule SQLParser.Native do
  @moduledoc false

  @repository Keyword.fetch!(Mix.Project.config(), :repository)

  @version Keyword.fetch!(Mix.Project.config(), :version)

  use RustlerPrecompiled,
    otp_app: :sql_parser,
    crate: :sql_parser,
    base_url: "#{@repository}/releases/download/v#{@version}",
    force_build: System.get_env("SQL_PARSER_BUILD") === "true",
    targets:
      ~w[aarch64-apple-darwin aarch64-unknown-linux-gnu aarch64-unknown-linux-musl x86_64-apple-darwin x86_64-unknown-linux-gnu x86_64-unknown-linux-musl],
    version: @version

  def parse(_sql, _dialect), do: :erlang.nif_error(:nif_not_loaded)

  def to_sql(_ast), do: :erlang.nif_error(:nif_not_loaded)
end
