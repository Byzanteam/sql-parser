use rustler::{types::tuple, Atom, Encoder, Env, Error, NifResult, NifTuple, Term};
use sqlparser::dialect::{BigQueryDialect, PostgreSqlDialect};
use sqlparser::parser::Parser;
use sqlparser::parser::ParserError::ParserError;

mod atoms {
    rustler::atoms! {
      ok,
      error,
    }
}

#[derive(NifTuple)]
struct Response {
    status: Atom,
    message: String,
}

#[rustler::nif]
fn parse(query: &str, dialect_str: &str) -> NifResult<Response> {
    let result = match dialect_str {
        "bigquery" => Parser::parse_sql(&BigQueryDialect {}, query),
        "postgres" => Parser::parse_sql(&PostgreSqlDialect {}, query),
        _ => Err(ParserError(
            "Parser for this dialect is not supported.".to_string(),
        )),
    };
    match result {
        Ok(v) => Ok(Response {
            status: atoms::ok(),
            message: serde_json::to_string(&v).unwrap(),
        }),
        Err(v) => Ok(Response {
            status: atoms::error(),
            message: v.to_string(),
        }),
    }
}

#[rustler::nif]
fn to_sql(json: &str) -> NifResult<Response> {
    let nodes: Vec<sqlparser::ast::Statement> = serde_json::from_str(json).unwrap();

    let mut parts = vec![];
    for node in nodes {
        parts.push(format!("{}", node))
    }

    Ok(Response {
        status: atoms::ok(),
        message: parts.join("\n"),
    })
}

#[rustler::nif]
fn split_with_parser<'a>(env: Env<'a>, sql: &'a str) -> NifResult<Term<'a>> {
    match pg_query::split_with_parser(sql) {
        Ok(statements) => {
            let mut result = Vec::new();
            for item in statements {
                result.push(item.encode(env));
            }

            Ok(tuple::make_tuple(
                env,
                &[atoms::ok().encode(env), result.encode(env)],
            ))
        }
        Err(err) => {
            let error_message = err.to_string();
            Err(Error::Term(Box::new(error_message)))
        }
    }
}

rustler::init!(
    "Elixir.SQLParser.Native",
    [parse, to_sql, split_with_parser]
);
