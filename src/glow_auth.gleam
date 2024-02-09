import gleam/uri.{type Uri}
import gleam/http/request.{type Request}
import gleam/string

fn build_bearer_token(token: String) -> String {
  ["Bearer", token]
  |> string.join(" ")
}

/// Prepend an access token as an authorization header bearer token
pub fn authorization_header(r: Request(body), token: String) -> Request(body) {
  token
  |> build_bearer_token
  |> request.prepend_header(r, "authorization", _)
}

/// A client credentials with an id and secret.
///
/// Use the 'site' to set a base Uri, perhaps useful when
/// token and auth uri's are relative.
pub type Client(body) {
  Client(id: String, secret: String, site: Uri)
}
