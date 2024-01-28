//// Token Request functions.

import gleam/string
import gleam/bit_array
import gleam/uri.{type Uri}
import gleam/http/request.{type Request}
import glow_auth.{type Client}
import glow_auth/token_request_builder.{type TokenRequestBuilder}
import glow_auth/uri/uri_builder.{type UriAppendage}

/// Build a token request using a code in 
/// [Authorization Code grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3).
///
/// Note that the redirect_uri must be identical to usage in the
/// [Authorization Uri](./authorize_uri.html).
pub fn authorization_code(
  client: Client(body),
  token_uri: UriAppendage,
  code: String,
  redirect_uri: Uri,
) -> Request(String) {
  token_uri
  |> uri_builder.append(to: client.site)
  |> token_request_builder.from_uri()
  |> token_request_builder.put_param("grant_type", "authorization_code")
  |> token_request_builder.put_param("code", code)
  |> token_request_builder.put_param(
    "redirect_uri",
    uri.to_string(redirect_uri),
  )
  |> token_request_builder.put_param("client_id", client.id)
  |> add_auth(client, AuthHeader)
  |> token_request_builder.to_token_request()
}

/// Build a token request using just the client id/secret in
/// [Client Credentials grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4.2)
pub fn client_credentials(
  client: Client(body),
  token_uri: UriAppendage,
  auth_scheme: AuthScheme,
) -> Request(String) {
  token_uri
  |> uri_builder.append(to: client.site)
  |> token_request_builder.from_uri()
  |> token_request_builder.put_param("grant_type", "client_credentials")
  |> add_auth(client, auth_scheme)
  |> token_request_builder.to_token_request()
}

/// Build a token request using a 
/// [Refresh token](https://datatracker.ietf.org/doc/html/rfc6749#section-6)
pub fn refresh(
  client: Client(body),
  token_uri: UriAppendage,
  refresh_token: String,
) -> Request(String) {
  token_uri
  |> uri_builder.append(to: client.site)
  |> token_request_builder.from_uri()
  |> token_request_builder.put_param("grant_type", "refresh_token")
  |> token_request_builder.put_param("refresh_token", refresh_token)
  |> add_auth(client, AuthHeader)
  |> token_request_builder.to_token_request()
}

/// Confidential clients or other clients issued client credentials can
/// authenticate with the authorization server by means of auth header or 
/// the request body.
pub type AuthScheme {
  /// Clients in possession of a client password MAY use the HTTP Basic
  /// authentication scheme as defined in [RFC2617] to authenticate with
  /// the authorization server.  The client identifier is encoded using the
  /// "application/x-www-form-urlencoded" encoding.
  AuthHeader
  /// Alternatively, the authorization server MAY support including the
  /// client credentials in the request-body (client_id and client_secret).
  RequestBody
}

/// Add auth by means of either AuthHeader or RequestBody 
pub fn add_auth(
  rb: TokenRequestBuilder(a),
  client: Client(_),
  auth_scheme: AuthScheme,
) -> TokenRequestBuilder(a) {
  case auth_scheme {
    AuthHeader ->
      rb
      |> token_request_builder.map_request(add_client_basic_auth_header(
        client,
        _,
      ))
    RequestBody -> add_auth_to_body(client, rb)
  }
}

pub fn add_client_basic_auth_header(
  client: Client(_),
  request: Request(a),
) -> Request(a) {
  let basic_auth_token = encode_auth(client)
  request
  |> add_basic_auth_header(basic_auth_token)
}

/// Add base64 encoded `authorization` header for basic auth.
///
/// Use this when sending the auth in the request headers.
pub fn add_basic_auth_header(
  request: Request(a),
  auth_token: String,
) -> Request(a) {
  let auth_header =
    ["Basic", auth_token]
    |> string.join(" ")

  request
  |> request.prepend_header("authorization", auth_header)
}

fn encode_auth(client: Client(_)) -> String {
  [client.id, client.secret]
  |> string.join(":")
  |> bit_array.from_string()
  |> bit_array.base64_encode(False)
}

/// Add the client id and secret params to the token TokenRequestBuilder
///
/// Use this when posting the auth in the request body.
pub fn add_auth_to_body(
  client: Client(_),
  rb: TokenRequestBuilder(body),
) -> TokenRequestBuilder(body) {
  rb
  |> token_request_builder.put_param("client_id", client.id)
  |> token_request_builder.put_param("client_secret", client.secret)
}
