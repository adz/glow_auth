//// Glow Auth is a gleam OAuth 2.0 helper library.
//// See [RFC6749](https://datatracker.ietf.org/doc/html/rfc6749).
//// 
//// The OAuth 2.0 authorization framework enables a third-party
//// application to obtain limited access to an HTTP service, either on
//// behalf of a resource owner by orchestrating an approval interaction
//// between the resource owner and the HTTP service, or by ahelper llowing the
//// third-party application to obtain access on its own behalf.
////
//// 
//// # Grant Types
//// 
//// The specification defines four grant types -- authorization code, implicit,
//// resource owner password credentials, and client credentials -- as well as an
//// extensibility mechanism for defining additional types.
//// 
//// Once granted an access token, it is typically included as a header
//// in your requests to the HTTP service.
//// 
//// Use [glow_auth#authorization_header](#authorization_header) to embed the header
//// to your request.
//// 
//// 
//// ## Authorization Code
//// 
//// The authorization code is obtained by using an authorization server
//// as an intermediary between the client and resource owner.  Instead of
//// requesting authorization directly from the resource owner, the client
//// directs the resource owner to an authorization server (via its
//// user-agent as defined in [RFC2616]), which in turn directs the
//// resource owner back to the client with the authorization code.
//// 
//// Use [glow_auth/authorize_uri](./glow_auth/authorize_uri.html) to build up an
//// authorization uri to use to redirect to.
//// 
//// On redirect back, you'll receive a `code` that can be used to request a token.
////  * Use [glow_auth/token_request#authorize_code](./glow_auth/token_request.html#authorize_code)
////    to do the token request.
////  * Use [glow_auth/access_token#decoder](./glow_auth/access_token.html#decoder)
////    to decode an access token response to an [Access Token](./glow_auth/access_token.html#AccessToken).
////
//// It's pretty common for these to have an expiry and support refresh flow.
////  * Use [glow_auth.token_request#refresh](./glow_auth/token_request.html#refresh)
////    to refresh a token.
//// 
//// ## Implicit
////
//// The implicit grant is a simplified authorization code flow optimized
//// for clients implemented in a browser using a scripting language such
//// as JavaScript.  In the implicit flow, instead of issuing the client
//// an authorization code, the client is issued an access token directly
//// (as the result of the resource owner authorization).  The grant type
//// is implicit, as no intermediate credentials (such as an authorization
//// code) are issued (and later used to obtain an access token).
//// 
//// Not supported.
//// 
////
//// ## Resource Owner Password Credentials
////
//// The resource owner password credentials (i.e., username and password)
//// can be used directly as an authorization grant to obtain an access
//// token.  The credentials should only be used when there is a high
//// degree of trust between the resource owner and the client (e.g., the
//// client is part of the device operating system or a highly privileged
//// application), and when other authorization grant types are not
//// available (such as an authorization code).
//// 
//// Not supported (yet).
////
//// 
//// ## Client Credentials
////
//// Client credentials are used as an authorization grant
//// typically when the client is acting on its own behalf (the client is
//// also the resource owner) or is requesting access to protected
//// resources based on an authorization previously arranged with the
//// authorization server.
////
////  * Use [glow_auth/token_request#client_credentials](./glow_auth/token_request.html#client_credentials)
////    to do the token request.
////  * Use [glow_auth/access_token#decoder](./glow_auth/access_token.html#decoder)
////    to decode an access token response to an [Access Token](./glow_auth/access_token.html#AccessToken).
////
//// # Refreshing
////
//// Issuing a refresh token is optional at the discretion of the
//// authorization server.  _If_ the authorization server issues a refresh
//// token, it is included when issuing an access token, typically also with
//// seconds till expiry.
////
////  * Use [glow_auth.token_request#refresh](./glow_auth/token_request.html#refresh)
////    to refresh a token.
////
////
//// # Concurrency Considerations
////
////  1. When receiving a code in an AuthCode flow redirect, be aware that if an
////     auth code is used more than once, it MUST be denied, and all tokens
////     previously issued based on it
////  1. When refreshing a token, typically the old access tokens are revoked.

import gleam/uri.{Uri}
import gleam/http/request.{Request}
import gleam/string

/// Prepend an access token as an authorization header bearer token
pub fn authorization_header(token: String, r: Request(body)) -> Request(body) {
  let header =
    ["Bearer", token]
    |> string.join(" ")

  r
  |> request.prepend_header("authorization", header)
}

pub type Client(body) {
  Client(id: String, secret: String, site: Uri)
}
