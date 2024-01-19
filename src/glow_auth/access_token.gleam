//// An access token is just a string, but it typically expires.
////
//// Depending on the type of grant, it may be refreshable via a separate
//// refresh token, or by directly requesting a new access token.
////
//// ...the intention is to generate this from the response given when
//// sending a token request.

import gleam/option.{type Option, None, Some}
import gleam/erlang.{Second}
import gleam/dynamic

/// Represents a token returned from an oauth2 provider
///
/// Note: expires_in is seconds till expiry from time of issue
pub type AccessToken {
  AccessToken(
    access_token: String,
    refresh_token: Option(String),
    expires_in: Option(Int),
    token_type: String,
  )
}

/// Decode an access token, only considering typical fields of
///  * access_token
///  * refresh_token (optional)
///  * expires (optional) - seconds till expiry from now
///  * token_type (optional) - typically "Bearer"
///
/// TODO: Seems like "expires_in" is also possible for "expires".
///
/// TODO: Decode with current datetime to give future expires_in.
///
/// TODO: Any other params are possible, so should be returned as a map.
pub fn decoder() {
  dynamic.decode4(
    AccessToken,
    dynamic.field("access_token", of: dynamic.string),
    dynamic.field("refresh_token", of: dynamic.optional(dynamic.string)),
    // could be expires_in, and is seconds into future from now -- store "now + this"
    dynamic.field("expires", of: dynamic.optional(dynamic.int)),
    // could be nil, missing, but typically "Bearer"
    dynamic.field("token_type", of: dynamic.string),
  )
  // also there are 'other' fields that may be returned
}

///  Returns a new `AccessToken` given the access token `string`.
pub fn new(token: String) -> AccessToken {
  AccessToken(
    access_token: token,
    refresh_token: None,
    expires_in: None,
    token_type: "Bearer",
  )
}

/// Does the access token have an expiry?
///
///Returns `true` unless `expires_in` is `None`.
pub fn has_an_expiry(access_token: AccessToken) -> Bool {
  option.is_some(access_token.expires_in)
}

// pub external fn universaltime() -> Result(List(String), Reason) =
// "gleam_erlang_ffi" "universaltime"

///  Determines if the access token has expired.
pub fn is_expired(access_token: AccessToken) -> Bool {
  case access_token.expires_in {
    Some(time) -> erlang.system_time(Second) > time
    None -> False
  }
}

pub fn normalize_token_type(token_type: Option(String)) -> String {
  case token_type {
    None -> "Bearer"
    Some("bearer") -> "Bearer"
    Some(str) -> str
  }
}
