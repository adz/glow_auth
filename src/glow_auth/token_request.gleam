//// Token Request builders

import gleam/uri.{Uri}
import gleam/http/request.{Request}
import glow_auth/client.{Client}
import glow_auth/uri/uri_builder.{UriAppendage}
import glow_auth/token_request/auth.{AuthHeader, AuthScheme}
import glow_auth/token_request/request_builder

/// Build a token request using Authorization Code grant
/// https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3
///
/// Notes: 
///  * The redirect_uri must be identical to usage in the Authorization Uri.
pub fn authorization_code(
  client: Client(body),
  token_uri: UriAppendage,
  code: String,
  redirect_uri: Uri,
) -> Request(String) {
  token_uri
  |> uri_builder.append(to: client.site)
  |> request_builder.from_uri()
  |> request_builder.put_param("grant_type", "authorization_code")
  |> request_builder.put_param("code", code)
  |> request_builder.put_param("redirect_uri", uri.to_string(redirect_uri))
  |> request_builder.put_param("client_id", client.id)
  |> auth.add_auth(client, AuthHeader)
  |> request_builder.to_token_request()
}

/// Build a token request using Client Credentials grant
/// https://datatracker.ietf.org/doc/html/rfc6749#section-4.4.2
pub fn client_credentials(
  client: Client(body),
  token_uri: UriAppendage,
  auth_scheme: AuthScheme,
) -> Request(String) {
  token_uri
  |> uri_builder.append(to: client.site)
  |> request_builder.from_uri()
  |> request_builder.put_param("grant_type", "client_credentials")
  |> auth.add_auth(client, auth_scheme)
  |> request_builder.to_token_request()
}

/// Build a token request using Refresh token
/// https://datatracker.ietf.org/doc/html/rfc6749#section-6
pub fn refresh(
  client: Client(body),
  token_uri: UriAppendage,
  refresh_token: String,
) -> Request(String) {
  token_uri
  |> uri_builder.append(to: client.site)
  |> request_builder.from_uri()
  |> request_builder.put_param("grant_type", "refresh_token")
  |> request_builder.put_param("refresh_token", refresh_token)
  |> auth.add_auth(client, AuthHeader)
  |> request_builder.to_token_request()
}
