//// An access token is just a string, but it typically expires.
////
//// Depending on the type of grant, it may be refreshable via a separate
//// refresh token, or by directly requesting a new access token.
////
//// ...the intention is to generate this from the response given when
//// sending a token request.

import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/erlang.{Second}
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/string

/// Represents a token returned from an oauth2 provider
///
/// Note: expires_in is seconds till expiry from time of issue
/// which is converted to expires_at by adding to time_now().
pub type AccessToken {
  AccessToken(
    access_token: String,
    token_type: String,
    refresh_token: Option(String),
    expires_at: Option(Int),
    scope: Option(String),
  )
}

/// Decode an access token
/// TODO: Any other params are possible, so should be returned as a map.
pub fn decoder() -> fn(Dynamic) -> Result(AccessToken, List(DecodeError)) {
  dynamic.decode5(
    from_decoded_response,
    dynamic.field("access_token", of: dynamic.string),
    dynamic.field("token_type", of: dynamic.string),
    dynamic.optional_field("refresh_token", of: dynamic.string),
    dynamic.optional_field("expires_in", of: dynamic.int),
    dynamic.optional_field("scope", of: dynamic.string),
  )
}

pub fn from_decoded_response(
  access_token: String,
  token_type: String,
  refresh_token: Option(String),
  expires_in: Option(Int),
  scope: Option(String),
) -> AccessToken {
  AccessToken(
    access_token: access_token,
    token_type: normalize_token_type(token_type),
    refresh_token: refresh_token,
    expires_at: option.map(expires_in, with: from_now),
    scope: scope,
  )
}

pub fn from_now(seconds: Int) -> Int {
  time_now() + seconds
}

pub fn decode_token_from_response(response: String) {
  json.decode(response, using: decoder())
}

///  Returns a new `AccessToken` given the access token `string`.
pub fn new(token: String) -> AccessToken {
  AccessToken(
    access_token: token,
    token_type: "Bearer",
    refresh_token: None,
    expires_at: None,
    scope: None,
  )
}

pub fn has_an_expiry(access_token: AccessToken) -> Bool {
  option.is_some(access_token.expires_at)
}

pub fn is_expired(access_token: AccessToken) -> Bool {
  is_expired_at(access_token, time_now())
}

pub fn is_expired_at(access_token: AccessToken, at: Int) -> Bool {
  case access_token.expires_at {
    Some(expires_time) -> at <= expires_time
    None -> False
  }
}

pub fn time_now() -> Int {
  // TODO: Use cross platform function for 'now'
  erlang.system_time(Second)
}

pub fn normalize_token_type(token_type: String) -> String {
  // Value is case insensitive.
  // https://ietf.org/doc/html/rfc6749#section-7.1
  //
  // Howerver, when used in authentication, for Bearer should always be 'Bearer'
  // https://tools.ietf.org/html/rfc6750#section-2.1
  case string.lowercase(token_type) {
    "bearer" -> "Bearer"
    str -> str
  }
}
