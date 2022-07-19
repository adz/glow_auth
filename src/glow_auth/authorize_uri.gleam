//// AuthorizeUri provides a builder to generate your Authorization Uri
//// to use in an Authorization Code or Implicit grant flow.
////
//// Since this is a redirection-based flow, the client must be capable of
//// interacting with the resource owner's user-agent (typically a web
//// browser) and capable of receiving incoming requests (via redirection)
//// from the authorization server.
//// 
//// Basically, send your user to the Authorization Uri, where it's expected
//// they will login or authenticate somehow, then they get redirected back.
////
//// In Authorization Code flow, they'll be redirected with a "code" in the uri,
//// which is short lived (10 minutes expiry recommended) that must be exchanged
//// for an Access Token separately.
////
//// In Implicit flow, they'll be redirected with a access token details
//// directly encoded in the uri.
////
//// In both cases, you can send over a `state` which will be sent back to you
//// on the redirect.
////
//// Failure is represented by the fields:
////  * error - invalid_request | unauthorized_client | access_denied
////            | unsupported_response_type | invalid_scope | server_error 
////            | temporarily_unavailable
////  * error_description - optional human readable
////  * error_uri - link to a 'more info' page
////  * state - the exact value previously specified in the authorization Uri
////
//// The exception is if there is a problem with the Redirect Uri, like not set,
//// or not registered in the Authorization provider, in which case the redirect
//// back will just not occur.

import gleam/uri.{Uri}
import gleam/option.{None, Option, Some}
import glow_auth/client.{Client}
import glow_auth/uri/params
import glow_auth/uri/uri_builder.{UriAppendage}

/// Represents the details needed to build an authorization Uri.
///
/// Use `build`, `set_scope`, `set_state` to build up one of these, then
/// `to_uri` to convert to a Uri.
pub type AuthUriSpec(body) {
  AuthUriSpec(
    client: Client(body),
    authorize_uri: UriAppendage,
    redirect_uri: Uri,
    scope: Option(String),
    state: Option(String),
  )
}

/// Convert an AuthUriSpec to an Authorization Uri.
pub fn to_uri(spec: AuthUriSpec(body)) -> Uri {
  let auth_uri =
    spec.authorize_uri
    |> uri_builder.append(to: spec.client.site)

  let q =
    params.new()
    |> params.put("response_type", "code")
    |> params.put("client_id", spec.client.id)
    |> params.put("redirect_uri", uri.to_string(spec.redirect_uri))
    |> params.put_option("state", spec.state)
    |> params.put_option("scope", spec.scope)
    |> params.to_query

  Uri(..auth_uri, query: Some(q))
}

/// Build a AuthUriSpec for an AuthCode authorize_uri.
///
/// Important things to note:
///  * The exact redirect_uri specified in this uri must also be provided
///    when requesting an access token.
pub fn build(client, authorize_uri, redirect_uri) -> AuthUriSpec(body) {
  AuthUriSpec(
    client: client,
    authorize_uri: authorize_uri,
    redirect_uri: redirect_uri,
    scope: None,
    state: None,
  )
}

/// Set the Redirect uri in the AuthUriSpec
pub fn set_redirect_uri(
  spec: AuthUriSpec(body),
  redirect_uri: Uri,
) -> AuthUriSpec(body) {
  AuthUriSpec(..spec, redirect_uri: redirect_uri)
}

/// Set the scope in the AuthUriSpec
pub fn set_scope(spec: AuthUriSpec(body), scope: String) -> AuthUriSpec(body) {
  AuthUriSpec(..spec, scope: Some(scope))
}

/// Set the state in the AuthUriSpec
pub fn set_state(spec: AuthUriSpec(body), state: String) -> AuthUriSpec(body) {
  AuthUriSpec(..spec, state: Some(state))
}
