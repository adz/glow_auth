import gleeunit
import gleeunit/should
import gleam/option.{None}
import gleam/http
import gleam/uri
import gleam/http/request.{type Request, Request}
import glow_auth
import gleam/result

pub fn main() {
  gleeunit.main()
}

fn make_request() {
  Request(
    method: http.Get,
    headers: [],
    body: Nil,
    scheme: http.Https,
    host: "example.com",
    port: None,
    path: "/",
    query: None,
  )
}

pub fn authorization_header_test() {
  make_request()
  |> glow_auth.authorization_header("123")
  |> request.get_header("authorization")
  |> should.equal(Ok("Bearer 123"))
}

pub fn client_constructor_test() {
  use example_uri <- result.then(uri.parse("https://example.com"))
  let c = glow_auth.Client(id: "123", secret: "abc", site: example_uri)

  c.id
  |> should.equal("123")

  c.secret
  |> should.equal("abc")

  c.site
  |> should.equal(example_uri)

  Ok("")
}
