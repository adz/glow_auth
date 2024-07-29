import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import gleam/uri
import gleeunit/should
import glow_auth.{Client}
import glow_auth/token_request.{RequestBody, ScopeList, client_credentials}
import glow_auth/uri/uri_builder

/// Tests that a scope is added to the request body as a space-deliminated string
/// of trimed scope values from a ScopeList.
pub fn scope_list_test() {
  let scopes = ["    first   ", "  second ", "      third    "]

  use example <- result.then(uri.parse("example.com"))
  let req =
    example
    |> Client("id", "secret", _)
    |> client_credentials(
      uri_builder.RelativePath("token"),
      RequestBody,
      Some(ScopeList(scopes)),
    )

  req.body
  |> uri.percent_decode
  |> result.unwrap("")
  |> string.split("&")
  |> list.filter(fn(s) { string.starts_with(s, "scope") })
  |> list.first
  |> should.equal(Ok("scope=first second third"))

  Ok("")
}
