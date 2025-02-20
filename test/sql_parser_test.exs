defmodule SQLParserTest do
  use ExUnit.Case, async: true

  doctest SQLParser

  describe "split_with_parser" do
    test "support enum" do
      sql = """
      CREATE TYPE ticket_state AS ENUM ('running', 'terminated');
      CREATE TYPE workflow_activity_instance_state AS ENUM ('active', 'completed', 'error');
      """

      assert {:ok, statements} = SQLParser.split_with_parser(sql)

      assert [
               """
               CREATE TYPE ticket_state AS ENUM ('running', 'terminated');\
               """,
               """
               CREATE TYPE workflow_activity_instance_state AS ENUM ('active', 'completed', 'error');\
               """
             ] === statements
    end

    test "support inherits" do
      sql = """
      CREATE TABLE cities (
        name       text,
        population real,
        elevation  int     -- (in ft)
      );

      CREATE TABLE capitals (
        state      char(2) UNIQUE NOT NULL
      ) INHERITS (cities);
      """

      assert {:ok, statements} = SQLParser.split_with_parser(sql)

      assert [
               """
               CREATE TABLE cities (
                 name       text,
                 population real,
                 elevation  int     -- (in ft)
               );\
               """,
               """
               CREATE TABLE capitals (
                 state      char(2) UNIQUE NOT NULL
               ) INHERITS (cities);\
               """
             ] === statements
    end

    test "comments" do
      sql = """
      -- UP

      SELECT 1;
      SELECT 2;

      -- DOWN

      SELECT -2;
      SELECT -1;
      """

      assert {:ok, statements} = SQLParser.split_with_parser(sql)

      assert [
               """
               -- UP

               SELECT 1;\
               """,
               """
               SELECT 2;\
               """,
               """
               -- DOWN

               SELECT -2;\
               """,
               """
               SELECT -1;\
               """
             ] = statements
    end

    test "returns error" do
      assert {:error, _message} = SQLParser.split_with_parser("this statement is not sql;")
    end
  end
end
