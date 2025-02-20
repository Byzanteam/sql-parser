defmodule SQLParser do
  @moduledoc """
  An SQL parser that uses [sqlparser](https://github.com/sqlparser-rs/sqlparser-rs.git) underneath.
  """

  @type ast() :: map()
  @type statement() :: binary()

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

  @doc """
  Splits the given SQL string into a list of statements using the pg_query library.

  ## Examples

      iex> SQLParser.split_with_parser("SELECT 1; SELECT 2;")
      {:ok, ["SELECT 1;", "SELECT 2;"]}
  """
  @spec split_with_parser(sql :: binary()) ::
          {:ok, [statement()]} | {:error, binary()}
  def split_with_parser(sql) do
    with {:ok, statements} <- SQLParser.Native.split_with_parser(sql) do
      statements =
        Enum.map(statements, fn statement ->
          statement
          |> String.trim()
          |> Kernel.<>(";")
        end)

      {:ok, statements}
    end
  end
end
