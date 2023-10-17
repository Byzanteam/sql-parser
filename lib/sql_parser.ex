defmodule SQLParser do
  @moduledoc """
  An SQL parser that uses [sqlparser](https://github.com/sqlparser-rs/sqlparser-rs.git) underneath.
  """

  @typep ast() :: map()

  @spec parse(sql :: binary(), dialect :: binary()) :: {:ok, [ast()]} | {:error, binary()}
  def parse(sql, dialect \\ "postgres") when dialect in ["bigquery", "postgres"] do
    with {:ok, json} <- SQLParser.Native.parse(sql, dialect) do
      Jason.decode(json)
    end
  end

  @spec to_sql(asts :: ast() | [ast()]) :: {:ok, binary()}
  def to_sql(ast) when is_map(ast), do: to_sql([ast])

  def to_sql(asts) when is_list(asts) do
    asts
    |> Jason.encode!()
    |> SQLParser.Native.to_sql()
  end
end
