//// An access token is just a string, but it typically expires.
////
//// Depending on the type of grant, it may be refreshable via a separate
//// refresh token, or by directly requesting a new access token.
////
//// ...the intention is to generate this from the response given when
//// sending a token request.

import gleam/option.{None, Option, Some}
import gleam/erlang.{Second}
import gleam/dynamic

/// Represents a token returned from an oauth2 provider
pub type AccessToken {
  AccessToken(
    access_token: String,
    refresh_token: Option(String),
    // is unix time - make it a proper date?
    expires_at: Option(Int),
    token_type: String,
  )
}

//
// // @standard ["access_token", "refresh_token", "expires_in", "token_type"]
// @spec new(%{binary => binary}) :: t
// def new(response) when is_map(response) do
//   {std, other} = Map.split(response, @standard)
//
//   struct(AccessToken,
//     access_token: std["access_token"],
//     refresh_token: std["refresh_token"],
//     expires_at: (std["expires_in"] || other["expires"]) |> expires_at,
//     token_type: std["token_type"] |> normalize_token_type(),
//     other_params: other
//   )
// end
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

///  Returns a new `AccessToken` given the access token `string` or a response `map`.
///
///  Note if giving a map, please be sure to make the key a `string` no an `atom`.
///
///  This is used by `OAuth2.Client.get_token/4` to create the `OAuth2.AccessToken` struct.
///
///  ### Example
///
///      iex> OAuth2.AccessToken.new("abc123")
///      %OAuth2.AccessToken{access_token: "abc123", expires_at: nil, other_params: %{}, refresh_token: nil, token_type: "Bearer"}
///
///      iex> OAuth2.AccessToken.new(%{"access_token" => "abc123"})
///      %OAuth2.AccessToken{access_token: "abc123", expires_at: nil, other_params: %{}, refresh_token: nil, token_type: "Bearer"}
pub fn new(token: String) -> AccessToken {
  AccessToken(
    access_token: token,
    refresh_token: None,
    expires_at: None,
    token_type: "Bearer",
  )
}

// was `expires?`
/// This is basically a decode from json blob returned from oauth
/// Determines if the access token will expire or not.
///
/// Returns `true` unless `expires_at` is `None`.
pub fn expires(access_token: AccessToken) -> Bool {
  option.is_some(access_token.expires_at)
}

// pub external fn universaltime() -> Result(List(String), Reason) =
// "gleam_erlang_ffi" "universaltime"

///  Determines if the access token has expired.
pub fn is_expired(access_token: AccessToken) -> Bool {
  case access_token.expires_at {
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
