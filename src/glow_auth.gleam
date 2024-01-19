import gleam/uri.{type Uri}
import gleam/http/request.{type Request}
import gleam/string

/// Prepend an access token as an authorization header bearer token
pub fn authorization_header(token: String, r: Request(body)) -> Request(body) {
  let header =
    ["Bearer", token]
    |> string.join(" ")

  r
  |> request.prepend_header("authorization", header)
}

/// A client credentials with an id and secret.
///
/// Use the 'site' to set a base Uri, perhaps useful when
/// token and auth uri's are relative.
pub type Client(body) {
  Client(id: String, secret: String, site: Uri)
}
