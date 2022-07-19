import gleam/string
import gleam/http/request.{Request}
import gleam/bit_string
import gleam/base
import glow_auth/client.{Client}
import glow_auth/token_request/request_builder.{RequestBuilder}

/// 4.4.  Client Credentials Grant
/// 4.4.2.  Access Token Request
/// https://datatracker.ietf.org/doc/html/rfc6749#section-4.4.2
///
/// The client MUST authenticate with the authorization server as
/// described in Section 3.2.1.
///
/// 3.2.1.  Client Authentication
/// https://datatracker.ietf.org/doc/html/rfc6749#section-3.2.1
/// 
/// Confidential clients or other clients issued client credentials MUST
/// authenticate with the authorization server as described in
/// Section 2.3 when making requests to the token endpoint.
///
/// 2.3.1.  Client Password
/// https://datatracker.ietf.org/doc/html/rfc6749#section-2.3.1
///
/// AuthHeader
/// ----------
/// Clients in possession of a client password MAY use the HTTP Basic
/// authentication scheme as defined in [RFC2617] to authenticate with
/// the authorization server.  The client identifier is encoded using the
/// "application/x-www-form-urlencoded" encoding...
///
/// RequestBody
/// -----------
/// Alternatively, the authorization server MAY support including the
/// client credentials in the request-body (client_id and client_secret).
pub type AuthScheme {
  AuthHeader
  RequestBody
}

pub fn encode_auth(client: Client(_)) -> String {
  [client.id, client.secret]
  |> string.join(":")
  |> bit_string.from_string()
  |> base.encode64(False)
}

/// Add to `authorization` header for basic auth.
pub fn add_basic_auth_header(
  client: Client(_),
  request: Request(a),
) -> Request(a) {
  let auth_header =
    ["Basic", encode_auth(client)]
    |> string.join(" ")

  request
  |> request.prepend_header("authorization", auth_header)
}

pub fn add_auth_to_body(
  client: Client(_),
  rb: RequestBuilder(body),
) -> RequestBuilder(body) {
  rb
  |> request_builder.put_param("client_id", client.id)
  |> request_builder.put_param("client_secret", client.secret)
}

pub fn add_auth(
  rb: RequestBuilder(a),
  client: Client(_),
  auth_scheme: AuthScheme,
) -> RequestBuilder(a) {
  case auth_scheme {
    AuthHeader ->
      rb
      |> request_builder.map_request(add_basic_auth_header(client, _))
    RequestBody -> add_auth_to_body(client, rb)
  }
}
