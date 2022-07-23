//// A builder to generate an Authorization Uri.
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
////  * error - set to one of:
////     * invalid_request
////     * unauthorized_client
////     * access_denied
////     * unsupported_response_type 
////     * invalid_scope 
////     * server_error 
////     * temporarily_unavailable
////  * error_description - optional human readable
////  * error_uri - link to a 'more info' page
////  * state - the exact value previously specified in the authorization Uri
////
//// The exception is if there is a problem with the Redirect Uri, like not set,
//// or not registered in the Authorization provider, in which case the redirect
//// back will just not occur.
////
//// Some requirements:
////  * MAY have query component
////  * MUST NOT have fragment component
////  * MUST use TLS
////  * MUST support GET method
////  * MAY support POST as well
////  * Params without value MUST be same as omission
////  * No repeat params
////  * MUST include response_type, typically json
////
//// Note that when redirected, the response:
////  * MUST include the "code" for AuthCode, or the "token" if Implicit
////  * MUST return error if response_type is missing or misunderstood
////  * MAY have query component
////  * MUST NOT have fragment component
////  * SHOULD use TLS for "code" or "token"
////  * Typically are registered in advance of usage
////  * Receiving response SHOULD NOT do js, but redirect again without exposing creds

import gleam/uri.{Uri}
import gleam/option.{None, Option, Some}
import glow_auth.{Client}
import glow_auth/uri/uri_builder.{UriAppendage}

/// Represents the details needed to build an authorization Uri.
///
/// Use [build](#build), [set_scope](#set_scope), [set_state](#set_state) to build
/// up one of these, then [to_code_authorization_uri](#to_code_authorization_uri)
/// or [to_implicit_authorization_uri](#to_implicit_authorization_uri)
/// to convert to a Uri.
pub type AuthUriSpec(body) {
  AuthUriSpec(
    client: Client(body),
    authorize_uri: UriAppendage,
    redirect_uri: Uri,
    scope: Option(String),
    state: Option(String),
  )
}

/// Supported response types
type AuthorizationResponseType {
  Token
  Code
}

/// Convert an AuthUriSpec to an Authorization Uri for `code` flow.
pub fn to_code_authorization_uri(spec: AuthUriSpec(body)) -> Uri {
  to_uri(spec, Code)
}

/// Convert an AuthUriSpec to an Authorization Uri for `implicit` flow.
pub fn to_implicit_authorization_uri(spec: AuthUriSpec(body)) -> Uri {
  to_uri(spec, Token)
}

fn to_uri(
  spec: AuthUriSpec(body),
  response_type: AuthorizationResponseType,
) -> Uri {
  let auth_uri =
    spec.authorize_uri
    |> uri_builder.append(to: spec.client.site)

  let response_type = case response_type {
    Token -> "token"
    Code -> "code"
  }

  let prepend_some = fn(list, key, maybe_value) {
    case maybe_value {
      Some(value) -> [#(key, value), ..list]
      None -> list
    }
  }

  let q =
    [
      #("response_type", response_type),
      #("client_id", spec.client.id),
      #("redirect_uri", uri.to_string(spec.redirect_uri)),
    ]
    |> prepend_some("state", spec.state)
    |> prepend_some("scope", spec.scope)
    |> uri.query_to_string()

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
///
/// This can be useful as it will be included on the redirect back.
pub fn set_state(spec: AuthUriSpec(body), state: String) -> AuthUriSpec(body) {
  AuthUriSpec(..spec, state: Some(state))
}
