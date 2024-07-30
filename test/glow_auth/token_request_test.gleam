import gleam/http/request.{type Request}
import gleam/list
import gleam/result
import gleam/string
import gleam/uri
import gleeunit/should
import glow_auth.{Client}
import glow_auth/token_request.{
  type Scope, DefaultScope, RequestBody, ScopeList, ScopeString,
  client_credentials,
}
import glow_auth/uri/uri_builder

fn make_request(
  scope: Scope,
  _handler: fn(Request(String)) -> Result(String, Nil),
) -> Result(Request(String), Nil) {
  use example <- result.then(uri.parse("example.com"))
  let req =
    example
    |> Client("id", "secret", _)
    |> client_credentials(uri_builder.RelativePath("token"), RequestBody, scope)

  Ok(req)
}

/// Tests that a scope is added to the request body as a space-deliminated string
/// of trimed scope values from a ScopeList.
pub fn scope_list_test() {
  let scopes = ["    first   ", "  second ", "      third    "]
  use req <- make_request(ScopeList(scopes))
  req.body
  |> extract_scope
  |> test_scope("first second third")

  Ok("")
}

/// Tests that a scope is added to the request body as a trimmed string of one or
/// more pre-joined, space-deliminated strings.
pub fn scope_string_test() {
  let scopes = "   third fourth fifth     "
  use req <- make_request(ScopeString(scopes))
  req.body
  |> extract_scope
  |> test_scope(string.trim(scopes))

  Ok("")
}

/// Tests that the scope is not added to the request if it's a DefaultScope.
pub fn default_scope_test() {
  use req <- make_request(DefaultScope)
  req.body
  |> extract_scope
  |> should.equal(Error(Nil))

  Ok("")
}

fn extract_scope(body: String) -> Result(String, Nil) {
  body
  |> uri.percent_decode
  |> result.unwrap("")
  |> string.split("&")
  |> list.filter(fn(s) { string.starts_with(s, "scope") })
  |> list.first
}

fn test_scope(actual: Result(String, Nil), expected: String) {
  actual |> should.equal(Ok("scope=" <> expected))
}
